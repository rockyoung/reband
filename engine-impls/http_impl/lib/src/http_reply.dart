import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

class HttpReply extends Reply<StreamedResponse> {
  @override
  int get statusCode => rawResponse.statusCode;

  @override
  String? get message => rawResponse.reasonPhrase;

  @override
  Map<String, String> get headers => Map.unmodifiable(rawResponse.headers);

  @override
  ByteStream get bodyStream => rawResponse.stream;

  late final FutureOr<Response> response = Response.fromStream(rawResponse);

  FutureOr<Uint8List> get bodyBytes async => (await response).bodyBytes;

  FutureOr<String> get bodyString async => (await response).body;

  HttpReply(StreamedResponse rawResponse, int timeConsuming)
      : super(rawResponse, timeConsuming);
}
