import 'dart:async';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:reband_restful/reband_restful.dart';
import 'http_apply.dart';
import 'http_reply.dart';

final httpLogger = Logger('reband_restful.http');

/// A [ApplyIntervener] and [ReplyIntervener] implementation which logging http
/// request and response data.
class HttpLoggingIntervener
    implements ApplyIntervener<HttpApply>, ReplyIntervener<HttpReply> {
  /// Whether run in the debug mode, is also the main control for this logger.
  ///
  /// dart's tree-shake depend on constant, this package is not designed for
  /// aimming to flutter only, so we can not import any flutter packages, and
  /// the result is we can not use `kDebugMode` inside library directly.
  final bool inDebugMode;

  /// Whether logging body for [StreamedRequest].
  final bool logStreamed;

  /// Whether logging body for [MultipartRequest].
  final bool logMultipart;

  /// Intervener that logs both [Apply] (request) and [Reply] (response) data.
  ///
  /// If param [inDebugMode] is `false`, no [LogRecord] will be emitted, the
  /// 'apply' and 'reply' from upper intervener will be returned immediately,
  /// since logging http data has potential to leak sensitive information, the
  /// best practice for this is to use the top-level constant `kDebugMode` in
  /// flutter apps.
  ///
  /// [logStreamed] and [logMultipart] are parameters for fine-grain logging
  /// control. Logging streamed or multipart body-data(usually is or has file
  /// bytes) are time-consuming, resource-wasteful and meaningless, so their
  /// value are `false` by default, pass `true` correspondingly to enable.
  ///
  /// *NOTE*:
  ///  - the byte string of streamed/multipart body are decoded only by `UTF8`
  /// before print.
  ///  - the entire response body of 'reply' returned by [afterResponse] which
  /// has been logged is actually known in advance while running in debug mode,
  /// if you plant to use [Reply.bodyStream] to do some stream listening after
  /// this intervener in debug mode, it probably can not be able to achieve the
  /// effect you want, for example the feature of downloading progress.
  const HttpLoggingIntervener({
    required this.inDebugMode,
    this.logStreamed = false,
    this.logMultipart = false,
  });

  @override
  FutureOr<HttpApply> beforeRequest(HttpApply apply) async {
    if (!inDebugMode) return apply;

    final log = StringBuffer('\n--> ${apply.method} ${apply.uri}\n');

    apply.headers.forEach((k, v) => log.writeln('$k: $v'));

    final request = await apply.submit();
    if (request is Request) {
      log.writeln(request.body);
    } else if ((request is StreamedRequest && logStreamed) ||
        (request is MultipartRequest && logMultipart)) {
      // It is the main performance bottleneck here, have no idea
      // that how to optimize for this.
      log.writeln(await request.finalize().bytesToString());
    } else {
      log.writeln('(streamed/multipart body bytes...)');
    }

    log.write('--> END ${apply.method}');
    final bodySize = request.contentLength;
    if (bodySize != null && bodySize > -1) {
      log.write(' ($bodySize-byte request body)');
    }
    log.writeln();

    httpLogger.info(log.toString());

    return apply;
  }

  @override
  FutureOr<HttpReply> afterResponse(HttpReply reply) async {
    if (!inDebugMode) return reply;

    final log = StringBuffer('\n<-- ${reply.statusCode}');
    log.write(' ${reply.message}');
    log.write(' ${reply.rawResponse.request?.url}');
    log.writeln(' (${reply.timeConsuming}ms)');

    reply.headers.forEach((k, v) => log.writeln('$k: $v'));

    log.writeln(await reply.bodyString);

    final bodySize = (await reply.bodyBytes).length;
    log.writeln('<-- END HTTP ($bodySize-byte response body)');

    httpLogger.info(log.toString());

    return reply;
  }
}
