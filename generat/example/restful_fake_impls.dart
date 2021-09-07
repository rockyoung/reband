// Fake implementations of reband_restful interfaces for example to the
// generat_example.dart.

import 'package:reband_restful/reband_restful.dart';

class FakeRequest {}

class FakeResponse {}

class FakeClient {}

class FakeApply extends Apply<FakeRequest> {
  const FakeApply(
    this.method,
    this.uri, {
    Map<String, String>? headers,
    this.body,
  }) : headers = headers ?? Apply.emptyHeaders;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  final Map<String, String> headers;

  @override
  final dynamic body;

  @override
  FakeApply clone({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    dynamic body,
  }) =>
      FakeApply(
        method ?? this.method,
        uri ?? this.uri,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );

  @override
  FakeRequest submit() => FakeRequest();
}

class FakeReply extends Reply<FakeResponse> {
  FakeReply(FakeResponse rawResponse)
      : super(rawResponse, (_) => 0, (_) => <String, String>{}, (_) => null);
}

class FakeReband extends Reband<FakeClient, FakeApply, FakeReply> {
  FakeReband(String baseUrl) : super(FakeClient(), baseUrl);

  @override
  FakeApply buildApply(String method, Uri uri,
          {Map<String, String>? headers, dynamic body}) =>
      FakeApply(method, uri, headers: headers, body: body);

  @override
  Future<FakeReply> launch(FakeApply apply) async {
    // final fakeRequest = apply.fill();
    // final fakeResponse = await engine.send(fakeRequest);
    return FakeReply(FakeResponse());
  }
}
