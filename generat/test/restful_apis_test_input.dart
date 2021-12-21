import 'package:reband_restful/reband_restful.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  r'''RESTfulApis annotation can not target on CLASS `BadConcreteClass` (enum, mixin and mixin application, these special kind of classes are illegal too)! ONLY ABSTRACT CLASS are supported.''',
  element: false,
)
@RESTfulApis()
class BadConcreteClass {}
