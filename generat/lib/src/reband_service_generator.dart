/// @nodoc
import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:reband_restful/reband_restful.dart' as reband;
import 'package:source_gen/source_gen.dart';

/// Read all informations from annotations and annotating elements, then
/// generate implementation code for all well annotated abstract methods
/// in a concrete class.
class RebandServiceGenerator
    extends GeneratorForAnnotation<reband.RESTfulApis> {
  /// Generated field name for instance of [reband.Reband] type, which expected
  /// to get from [reband.RebandService]'s type argument.
  static const _gfnReband = r'_reband$';

  /// Generated variable name for path [Map] in function local.
  static const _gvnPathMap = r'composedPath$';

  static const _gvnQueryMap = r'composedQuery$';
  static const _gvnHeaderMap = r'composedHeader$';
  static const _gvnFieldMap = r'composedField$';
  static const _gvnPartList = r'composedPart$';
  static const _gvnBodyList = r'composedBody$';

  static const _ignore = '// ignore_for_class: equal_keys_in_map';

  late final _logger = Logger('reband_generat.service');

  late ClassElement _annotatedClass;

  late String _rebandType;

  late String _basePath;

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // The definition of ClassElement from analyzer is a little broad, that
    // includes not only class in general (concrete or abstract), but also
    // mixin (or mixin application) and enum class, which are special kind
    // of class too.
    //
    // Marked class by RESTfulApi annotation will be used as an interface for
    // the generated implementation class only with the keyword `implements`,
    // so we should filter out enum, mixin and mixin application.
    if (element is! ClassElement ||
        !element.isAbstract ||
        element.isEnum ||
        element.isMixin ||
        element.isMixinApplication) {
      throw InvalidGenerationSourceError(
          'RESTfulApis annotation can not target on ${element.kind.name} `${element.displayName}` (enum, mixin and mixin application, these special kind of classes are illegal too)! ONLY ABSTRACT CLASS are supported.');
    }

    // final rebandServiceTc = _getCheckerOf(reband.RebandService);
    // try {
    //   final rebandServiceType = element.allSupertypes
    //       .firstWhere(rebandServiceTc.isAssignableFromType);
    //   _rebandType =
    //       _getRecursivelyUntilItsExactly(rebandServiceType, rebandServiceTc)
    //           .typeArguments[0]; // RebandService has only one type argument.
    // } catch (_) {
    //   throw InvalidGenerationSourceError(
    //       '`${element.displayName}` MUST directly or indirectly inherited from `RebandService` by `extends`, `implements` or `with`!');
    // }

    // final rebandTc = _getCheckerOf(reband.Reband);
    // if (rebandTc.isExactlyType(_rebandType)) {
    //   throw InvalidGenerationSourceError(
    //       'Avoid using `Reband` as type parameter for `RebandService`, replace `Reband` with one of it\'s sub-class that you have implemented.');
    // }
    // try {
    //   final rebandType = (_rebandType as InterfaceType)
    //       .allSupertypes
    //       .firstWhere(rebandTc.isAssignableFromType);
    //   _replyType = _getRecursivelyUntilItsExactly(rebandType, rebandTc)
    //       .typeArguments[2]; // Reply type arg is at index 2 of Reband.
    // } catch (e) {
    //   rethrow;
    // }

    _basePath = annotation.peek('basePath')?.stringValue ?? '';

    final annDartType = annotation.objectValue.type;
    if (annDartType is InterfaceType) {
      final exactlyRESTfulApis =
          _getRecursivelyUntilItsExactly(annDartType, typeChecker);
      final rebandDt = exactlyRESTfulApis.typeArguments[0];
      final rebandTc = _getCheckerOf(reband.Reband);
      if (rebandTc.isAssignableFromType(rebandDt)) {
        _rebandType = rebandDt.toString();
      } else {
        _rebandType = (reband.Reband).toString();
      }
    } else {
      _rebandType = (reband.Reband).toString();
    }

    _annotatedClass = element;

    return _generateImplementationClassFormattedString();
  }

  final _typeCheckerMap = <Type, TypeChecker>{};
  TypeChecker _getCheckerOf(Type type) =>
      _typeCheckerMap.putIfAbsent(type, () => TypeChecker.fromRuntime(type));

  InterfaceType _getRecursivelyUntilItsExactly(
      InterfaceType type, TypeChecker byChecker) {
    if (byChecker.isExactlyType(type)) return type;

    final superType =
        type.allSupertypes.firstWhere(byChecker.isAssignableFromType);

    return _getRecursivelyUntilItsExactly(superType, byChecker);
  }

  String _generateImplementationClassFormattedString() {
    final classBuilder = Class((builder) => builder
      ..name = '_\$${_annotatedClass.name}'
      // ..extend = refer(_annotatedClass.name)
      // `extends` make both abstract and implement class have more
      // restrictions to their constructors.
      ..implements.add(refer(_annotatedClass.name))
      ..fields.add(_buildRebandFiled())
      ..constructors.add(_buildConstructor())
      ..methods.addAll(_verifyAllMethodsCorrectnessAndBuild()));

    return DartFormatter().format('$_ignore\n'
        '${classBuilder.accept(DartEmitter())}');
  }

  Field _buildRebandFiled() => Field((builder) => builder
    ..name = _gfnReband
    ..type = refer(_rebandType)
    ..modifier = FieldModifier.final$);

  Constructor _buildConstructor() => Constructor((builder) => builder
    ..requiredParameters.add(
      Parameter((paramBuilder) => paramBuilder
        ..name = _gfnReband
        ..toThis = true),
    ));

  Iterable<Method> _verifyAllMethodsCorrectnessAndBuild() {
    final targetMethods = <ConstantReader, MethodElement>{};

    for (final method in _annotatedClass.methods) {
      if (method.isAbstract) {
        final returnType = method.returnType;
        if (!returnType.isDartAsyncFuture) {
          throw InvalidGenerationSourceError(
              'The return type of abstract method `${method.name}` in `${_annotatedClass.name}` is not `Future`!');
        }

        final futureTypeArg =
            (returnType as ParameterizedType).typeArguments[0];
        final replyTc = _getCheckerOf(reband.Reply);
        if (!replyTc.isAssignableFromType(futureTypeArg)) {
          throw InvalidGenerationSourceError(
              'The `Future` type argument of abstract method `${method.name}` in `${_annotatedClass.name}` should be type of `Reply`');
        }

        final hmAnnCr = _getAnnotationCr(method, reband.HttpMethod);
        if (hmAnnCr.isNull) {
          throw InvalidGenerationSourceError(
              'Abstract method `${method.name}` in `${_annotatedClass.name}` dose not have any specific http method annotation targeted on, reband_generat does not know how to generate code for you!');
        } else {
          targetMethods[hmAnnCr] = method;
        }
      } else if (!method.isStatic) {
        throw InvalidGenerationSourceError(
            'Abstract class `${_annotatedClass.name}` should not have concrete method `${method.name}` (except static) since reband_generat only using `implicit interfaces` to implement classes for you!');
      }
    }

    return targetMethods.entries.map((e) => _buildMethod(e.key, e.value));
  }

  // bool _isAnnotating(Element onEle, Type withType) =>
  //     _getAnnotationDo(onEle, withType) != null;

  /// Get annotation of [Type] wrapped in [ConstantReader] from [Element], May
  /// return `_NullConstant` and should check it by [ConstantReader.isNull].
  ConstantReader _getAnnotationCr(Element fromEle, Type ofType) =>
      ConstantReader(_getAnnotationDo(fromEle, ofType));

  /// Returns the first constant annotating [fromEle] assignable to [ofType].
  /// Otherwise returns null. see [TypeChecker.firstAnnotationOf] for more
  /// details.
  DartObject? _getAnnotationDo(Element fromEle, Type ofType) =>
      _getCheckerOf(ofType)
          .firstAnnotationOf(fromEle, throwOnUnresolved: false);

  Method _buildMethod(ConstantReader httpMethodAnnCr, MethodElement mEle) {
    // _logger.info('mEle.toString(): ${mEle.toString()}');
    // _logger.info('mEle.name: ${mEle.name}');
    // _logger.info('mEle.displayName: ${mEle.displayName}');
    // _logger.info('mEle.getDisplayString: '
    //     '${mEle.getDisplayString(withNullability: false)}');
    //   final method = _getMethodAnnotation(m);

    final pathReferMap = <Expression, Reference>{};
    final queryMapSb = StringBuffer('<String, dynamic>')..writeln('{');
    final headerMapSb = StringBuffer('<String, String>')..writeln('{');
    final fieldMapSb = StringBuffer('<String, dynamic>')..writeln('{');
    final multipartLis = <Expression>[];
    final bodyReferLis = <Reference>[];

    final headerMapCr = _getAnnotationCr(mEle, reband.HeaderMap);
    if (!headerMapCr.isNull) {
      headerMapCr.read('value').mapValue.forEach((key, value) {
        final keyStr = key?.toStringValue() ?? '';
        final valueStr = value?.toStringValue() ?? '';
        headerMapSb.writeln('\'$keyStr\': \'$valueStr\',');
      });
    }

    final mbRequiredParams = <Parameter>[];
    final mbOptionalParams = <Parameter>[];

    for (final pe in mEle.parameters) {
      if (pe.isNotOptional) {
        mbRequiredParams.add(_buildParameter(pe));
      } else {
        mbOptionalParams.add(_buildParameter(pe));
      }

      if (pe.metadata.isEmpty) {
        _logger.warning(
            'Parameter `${pe.name}` does not have any annotation, means useless in generated code, conside remove or add an annotation on it.');
        continue; // skip for faster
      }

      _readAnnPath(pe, pathReferMap);
      _readAnnQuery(pe, queryMapSb);
      _readAnnHeader(pe, headerMapSb);
      _readAnnField(pe, fieldMapSb);
      _readAnnPart(pe, multipartLis);
      _readAnnBody(pe, bodyReferLis);
    }

    final methodBodyCodes = <Code>[];

    final executeNamedArgs = <String, Expression>{};

    if (pathReferMap.isNotEmpty) {
      methodBodyCodes.add(literalMap(
        pathReferMap,
        refer((String).toString()),
        refer((dynamic).toString()),
      ).assignFinal(_gvnPathMap).statement);

      executeNamedArgs['pathMapper'] = refer(_gvnPathMap);
    }

    if (queryMapSb.length > 19) {
      queryMapSb.writeln('};');
      methodBodyCodes.add(Code('final $_gvnQueryMap = $queryMapSb'));

      executeNamedArgs['queries'] = refer(_gvnQueryMap);
    }

    if (headerMapSb.length > 18) {
      headerMapSb.writeln('};');
      methodBodyCodes.add(Code('final $_gvnHeaderMap = $headerMapSb'));

      executeNamedArgs['headers'] = refer(_gvnHeaderMap);
    }

    if (fieldMapSb.length > 19) {
      fieldMapSb.writeln('};');
      methodBodyCodes.add(Code('final $_gvnFieldMap = $fieldMapSb'));

      executeNamedArgs['fields'] = refer(_gvnFieldMap);
    }

    if (multipartLis.isNotEmpty) {
      methodBodyCodes.add(literalList(
        multipartLis,
        refer((reband.Multipart).toString()),
      ).assignFinal(_gvnPartList).statement);

      executeNamedArgs['multiparts'] = refer(_gvnPartList);
    }

    if (bodyReferLis.isNotEmpty) {
      methodBodyCodes.add(literalList(
        bodyReferLis,
        refer((dynamic).toString()),
      ).assignFinal(_gvnBodyList).statement);

      executeNamedArgs['annBodies'] = refer(_gvnBodyList);
    }

    final hmName = httpMethodAnnCr.peek('name')?.stringValue ?? '';
    final endPath = httpMethodAnnCr.peek('endPath')?.stringValue ?? '';
    final executeCallCode = refer('$_gfnReband.execute')
        .call([
          literalString(hmName),
          literalString(_basePath),
          literalString(endPath)
        ], executeNamedArgs)
        .returned
        .statement;

    methodBodyCodes.add(executeCallCode);

    return Method((methodBuilder) {
      // final a = mEle.typeParameters;
      // _logger.info('typeParameters of method($mEle): $a');
      methodBuilder
        ..annotations.add(refer('override'))
        ..name = mEle.displayName
        ..types.addAll(
          mEle.typeParameters.map((tpe) => refer(tpe.name)),
        )
        ..returns = refer(
          mEle.returnType.getDisplayString(
            withNullability: mEle.returnType.isNullable,
          ),
        )
        ..requiredParameters.addAll(mbRequiredParams)
        ..optionalParameters.addAll(mbOptionalParams)
        ..body = Block.of(methodBodyCodes);
    });
  }

  Parameter _buildParameter(ParameterElement fromPe) => Parameter((builder) {
        builder
          ..name = fromPe.name
          ..named = fromPe.isNamed
          ..required = fromPe.isRequiredNamed
          ..covariant = fromPe.isCovariant
          ..type = refer(
            fromPe.type.getDisplayString(
              withNullability: fromPe.type.isNullable,
            ),
          );

        final defaultValueStr = fromPe.defaultValueCode;
        if (defaultValueStr != null) {
          builder.defaultTo = Code(defaultValueStr);
        }
      });

  void _readAnnPath(ParameterElement pe, Map<Expression, Reference> map) {
    final pathAnnCr = _getAnnotationCr(pe, reband.Path);
    if (!pathAnnCr.isNull) {
      final name = pathAnnCr.peek('name')?.stringValue ?? pe.name;
      map[literalString(name)] = refer(pe.name);
    }
  }

  void _readAnnQuery(ParameterElement pe, StringBuffer codeStrBuffer) {
    final queriesAnnCr = _getAnnotationCr(pe, reband.Queries);
    if (!queriesAnnCr.isNull) {
      _checkParamMapTypeAndSpreadIt(pe, codeStrBuffer, 'Queries');
    }
    final queryAnnCr = _getAnnotationCr(pe, reband.Query);
    if (!queryAnnCr.isNull) {
      final name = queryAnnCr.peek('name')?.stringValue ?? pe.name;
      codeStrBuffer.writeln('\'$name\': ${pe.name},');
    }
  }

  void _readAnnHeader(ParameterElement pe, StringBuffer codeStrBuffer) {
    final headersAnnCr = _getAnnotationCr(pe, reband.Headers);
    if (!headersAnnCr.isNull) {
      _checkParamMapTypeAndSpreadIt(pe, codeStrBuffer, 'Headers',
          valueType: 'String');
    }
    final headerAnnCr = _getAnnotationCr(pe, reband.Header);
    if (!headerAnnCr.isNull) {
      final name = headerAnnCr.read('name').stringValue;
      codeStrBuffer.writeln('\'$name\': ${pe.name}.toString(),');
    }
  }

  void _readAnnField(ParameterElement pe, StringBuffer codeStrBuffer) {
    final fieldsAnnCr = _getAnnotationCr(pe, reband.Fields);
    if (!fieldsAnnCr.isNull) {
      _checkParamMapTypeAndSpreadIt(pe, codeStrBuffer, 'Fields');
    }
    final fieldAnnCr = _getAnnotationCr(pe, reband.Field);
    if (!fieldAnnCr.isNull) {
      final name = fieldAnnCr.peek('name')?.stringValue ?? pe.name;
      codeStrBuffer.writeln('\'$name\': ${pe.name},');
    }
  }

  void _readAnnPart(ParameterElement pe, List<Expression> list) {
    final partAnnCr = _getAnnotationCr(pe, reband.Part);
    if (!partAnnCr.isNull) {
      final name = partAnnCr.peek('name')?.stringValue ?? pe.name;
      final namedArgs = <String, Expression>{};
      final fileName = partAnnCr.peek('fileName')?.stringValue;
      if (fileName != null) {
        namedArgs['fileName'] = literalString(fileName);
      }
      final isFilePath = partAnnCr.read('isFilePath').boolValue;
      if (isFilePath) {
        namedArgs['valueIsPath'] = literalBool(isFilePath);
      }

      list.add(refer((reband.Multipart).toString()).newInstance([
        literalString(name),
        refer(pe.name),
      ], namedArgs));
    }
  }

  void _readAnnBody(ParameterElement pe, List<Reference> list) {
    final bodyAnnCr = _getAnnotationCr(pe, reband.Body);
    if (!bodyAnnCr.isNull) list.add(refer(pe.name));
  }

  void _checkParamMapTypeAndSpreadIt(
    ParameterElement paramElem,
    StringBuffer codeStrBuffer,
    String annNameForLogger, {
    String keyType = 'String',
    String valueType = 'dynamic',
  }) {
    final typeDisplay = paramElem.type.getDisplayString(
      withNullability: paramElem.type.isNullable,
    );

    if (typeDisplay.startsWith('Map<$keyType, $valueType>')) {
      final String spreadCode;
      if (paramElem.type.isNullable) {
        spreadCode = '...?${paramElem.name},';
      } else {
        spreadCode = '...${paramElem.name},';
      }
      codeStrBuffer.writeln(spreadCode);
    } else {
      _logger.severe('`$annNameForLogger` annotations should only'
          ' target on `Map<$keyType, $valueType>` type parameter,'
          ' and `${paramElem.name}` is not a valid map!');
    }
  }
}

extension DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;
}
