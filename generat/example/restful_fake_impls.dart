/// Fake implementations of `reband_restful` library just for the example to
/// generat_example.dart.

import 'package:reband_restful/reband_restful.dart';

class FakeRequest {}

class FakeResponse {}

class FakeClient {}

class FakeApply extends Apply<FakeRequest> {
  const FakeApply();

  @override
  String get method => 'GET';

  @override
  Uri get uri => Uri();

  @override
  Map<String, String> get headers => Apply.emptyHeaders;

  @override
  dynamic get body => null;

  @override
  Future<FakeRequest> submit() async => FakeRequest();
}

class FakeReply extends Reply<FakeResponse> {
  FakeReply(FakeResponse rawResponse) : super(rawResponse, 100);

  @override
  Stream<List<int>> get bodyStream => Stream.empty();

  @override
  Map<String, String> get headers => {};

  @override
  String? get message => 'OK';

  @override
  int get statusCode => 200;
}

class FakeReband extends Reband<FakeClient, FakeApply, FakeReply> {
  FakeReband(String baseUrl) : super(FakeClient(), baseUrl);

  @override
  FakeApply buildApply(String method, Uri uri,
          {Map<String, String>? headers, dynamic body}) =>
      FakeApply();

  @override
  Future<FakeReply> launch(FakeApply apply) async {
    // final fakeRequest = await apply.submit();
    // final fakeResponse = await engine.send(fakeRequest);
    return FakeReply(FakeResponse());
  }
}
