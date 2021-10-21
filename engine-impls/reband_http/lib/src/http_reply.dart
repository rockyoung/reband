import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

class HttpReply extends Reply {
  final StreamedResponse rawResponse;

  @override
  final int timeConsumed;

  HttpReply(this.rawResponse, this.timeConsumed);

  @override
  int get statusCode => rawResponse.statusCode;

  @override
  String? get message => rawResponse.reasonPhrase;

  @override
  late final Map<String, String> headers =
      Map.unmodifiable(rawResponse.headers);

  @override
  ByteStream get bodyStream => rawResponse.stream;

  late final FutureOr<Response> response = Response.fromStream(rawResponse);

  @override
  late final FutureOr<Uint8List> bodyBytes =
      (() async => (await response).bodyBytes)();

  @override
  late final FutureOr<String> bodyString =
      (() async => (await response).body)();
}
