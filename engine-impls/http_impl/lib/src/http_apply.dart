import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

class HttpApply extends Apply<BaseRequest> {
  const HttpApply(
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
  HttpApply clone({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    dynamic body,
  }) =>
      HttpApply(
        method ?? this.method,
        uri ?? this.uri,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );

  @override
  BaseRequest submit() {
    final BaseRequest request;
    if (isStreamed()) {
      request = _createStreamed();
    } else {
      request = Request(method, uri);
    }
    return request;
  }

  StreamedRequest _createStreamed() {
    final requset = StreamedRequest(method, uri);
    if (headers.isNotEmpty) {
      requset.headers.addAll(headers);
    }
    (body as Stream<List<int>>).listen(
      requset.sink.add,
      onDone: requset.sink.close,
      onError: requset.sink.addError,
    );
    return requset;
  }
}
