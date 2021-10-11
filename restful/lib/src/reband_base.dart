import 'package:meta/meta.dart';

import 'apply.dart';
import 'intervener.dart';
import 'multipart.dart';
import 'reply.dart';
import 'utils.dart';

/// Main abstract class of `reband_restful`, it emit all requests through
/// [execute] method (in general, the calls are in the generated classes),
/// create real HTTP connection through [launch] by the [engine] instance,
/// manage the [Intervener]s and make the usage of HTTP calling consistently.
abstract class Reband<E, A extends Apply, R extends Reply> {
  /// The engine of this reband, that is the real HTTP network client .
  E get engine;

  /// The base url string used for all networks made by this reband.
  String get baseUrl;

  /// [ApplyIntervener]s for all [Apply]s.
  final applyInterveners = <ApplyIntervener<A>>[];

  /// [ReplyIntervener]s for all [Reply]s.
  final replyInterveners = <ReplyIntervener<R>>[];

  /// Clear all apply and reply interveners that have been set, add them to
  /// reset correspondingly by their runtime type.
  ///
  /// null or empty [interveners] will just clear them.
  @nonVirtual
  void resetInterveners(List<Intervener>? interveners) {
    applyInterveners.clear();
    replyInterveners.clear();

    if (interveners == null || interveners.isEmpty) {
      return;
    }

    for (final intervener in interveners) {
      var isAcceptable = false;
      if (intervener is ApplyIntervener<A>) {
        isAcceptable = true;
        applyInterveners.add(intervener);
      }
      if (intervener is ReplyIntervener<R>) {
        isAcceptable = true;
        replyInterveners.add(intervener);
      }
      if (!isAcceptable) {
        rebandLogger.warning(
            'You are passing `Intervener` which is neither an ApplyIntervener nor a ReplyIntervener, it will be ignored by simply dropping!');
      }
    }
  }

  Future<A> _interveneApply(A apply) async {
    if (applyInterveners.isEmpty) return apply;
    for (final ai in applyInterveners) {
      apply = await ai.beforeRequest(apply);
    }
    return apply;
  }

  Future<R> _interveneReply(R reply) async {
    if (replyInterveners.isEmpty) return reply;
    for (final ri in replyInterveners) {
      reply = await ri.afterResponse(reply);
    }
    return reply;
  }

  /// Core api for [Reband] instance, the easiest way to use it is do not use
  /// it (manually), let the `reband_generat` do the dirty work for you.
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

  /// Building request [Uri] to create an [Apply].
  ///
  /// Override this to implement your own [Uri] build logic for [Apply].
  @protected
  Uri buildApplyUri(String basePath, String endPath,
      Map<String, dynamic>? pathMapper, Map<String, dynamic>? queries) {
    final fullUrl = combineHttpUrl(baseUrl, basePath);
    return buildHttpUriFrom(
      combineHttpUrl(fullUrl, endPath),
      pathReplaces: pathMapper,
      appendQueries: queries,
    );
  }

  /// Pick a request body to create an [Apply].
  ///
  /// Override this to implement your own `Body` selection for [Apply].
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

  /// Use the passing params to create the [A] type [Apply] instance, it just
  /// calls the constructor of [A] usually.
  @protected
  A buildApply(String method, Uri uri,
      {Map<String, String>? headers, dynamic body});

  /// Building the real request (by [Apply.submit]) and sending it through the
  /// [engine] client, await the real response to build corresponding [Reply]
  /// for return.
  @protected
  Future<R> launch(A apply);
}
