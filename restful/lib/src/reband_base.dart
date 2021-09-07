import 'package:meta/meta.dart';

import 'apply.dart';
import 'intervener.dart';
import 'multipart.dart';
import 'reply.dart';
import 'utils.dart';

abstract class Reband<E, A extends Apply, R extends Reply> {
  ///
  final E engine;

  /// The base url string
  final String baseUrl;

  ///
  final _applyInterveners = <ApplyIntervener<A>>[];

  ///
  final _replyInterveners = <ReplyIntervener<R>>[];

  Reband(this.engine, this.baseUrl, {List<Intervener>? interveners}) {
    _setInterveners(interveners);
  }

  @nonVirtual
  void _setInterveners(List<Intervener>? interveners) {
    rebandLogger.config(interveners);
    if (interveners == null || interveners.isEmpty) {
      return;
    }

    interveners.forEach((intervener) {
      var isAcceptable = false;
      if (intervener is ApplyIntervener<A>) {
        isAcceptable = true;
        _applyInterveners.add(intervener);
      }
      if (intervener is ReplyIntervener<R>) {
        isAcceptable = true;
        _replyInterveners.add(intervener);
      }
      if (!isAcceptable) {
        rebandLogger.warning(
            'You are passing `Intervener` which is neither an ApplyIntervener nor a ReplyIntervener, it will be ignored by simply dropping!');
      }
    });
  }

  Future<A> _interveneApply(A apply) async {
    if (_applyInterveners.isEmpty) return apply;
    for (final ai in _applyInterveners) {
      apply = await ai.beforeRequest(apply);
    }
    return apply;
  }

  Future<R> _interveneReply(R reply) async {
    if (_replyInterveners.isEmpty) return reply;
    for (final ri in _replyInterveners) {
      reply = await ri.afterResponse(reply);
    }
    return reply;
  }

  @nonVirtual
  Future<R> execute(
      final String method, final String basePath, final String endPath,
      {final Map<String, dynamic>? pathMapper,
      final Map<String, dynamic>? queries,
      final Map<String, String>? headers,
      final List<dynamic>? annBodies,
      final List<Multipart>? multiparts,
      final Map<String, dynamic>? fields}) async {
    var apply = buildApply(
        method,
        buildApplyUri(
          basePath,
          endPath,
          pathMapper,
          queries,
        ),
        headers: headers,
        body: pickApplyBody(
          annBodies,
          multiparts,
          fields,
        ));

    apply = await _interveneApply(apply);

    var reply = await launch(apply);

    reply = await _interveneReply(reply);
    return reply;
  }

  @protected
  Uri buildApplyUri(String basePath, String endPath,
      Map<String, dynamic>? pathMapper, Map<String, dynamic>? queries) {
    var fullUrl = combineHttpUrl(baseUrl, basePath);
    fullUrl = combineHttpUrl(fullUrl, endPath);
    return buildHttpUriFrom(
      fullUrl,
      pathReplaces: pathMapper,
      appendQueries: queries,
    );
  }

  @protected
  dynamic pickApplyBody(List<dynamic>? annBodies, List<Multipart>? multiparts,
      Map<String, dynamic>? fields) {
    // for now, we can not use `if (iterable?.isNotEmpty == true)`
    // to simplify the statement, check
    // https://github.com/dart-lang/language/issues/1224
    // and update below codes while it is supported.
    if (annBodies != null && annBodies.isNotEmpty) {
      return annBodies.last;
    }
    if (multiparts != null && multiparts.isNotEmpty) {
      return multiparts;
    }
    if (fields != null && fields.isNotEmpty) {
      return fields;
    }
  }

  ///
  @protected
  A buildApply(String method, Uri uri,
      {Map<String, String>? headers, dynamic body});

  /// Building the real request(by [Apply.submit]) and sending it through the
  /// [engine] client, await the real response to build corresponding [Reply]
  /// for return.
  @protected
  Future<R> launch(A apply);
}
