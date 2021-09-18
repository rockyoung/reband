import 'package:http/http.dart';
import 'package:reband_restful/reband_restful.dart';

class HttpApply extends Apply<BaseRequest> {
  @override
  final String method;

  @override
  final Uri uri;

  @override
  final Map<String, String> headers;

  @override
  final dynamic body;

  const HttpApply(
    this.method,
    this.uri, {
    Map<String, String>? headers,
    this.body,
  }) : headers = headers ?? Apply.emptyHeaders;

  /// Clone a new apply instance that only replacing the member indicated by
  /// optional named parameter with a non-null value.
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
  Future<BaseRequest> submit() async {
    final BaseRequest request;
    if (body is Stream<List<int>>) {
      request = _createStreamedRequest(body);
    } else if (body is List<Multipart>) {
      request = await _createMultipartRequest(body);
    } else {
      request = _createBodyKnownRequest();
    }
    return request;
  }

  StreamedRequest _createStreamedRequest(Stream<List<int>> streamBody) {
    final request = StreamedRequest(method, uri);
    if (headers.isNotEmpty) request.headers.addAll(headers);
    streamBody.listen(request.sink.add,
        onDone: request.sink.close, onError: request.sink.addError);
    return request;
  }

  Future<MultipartRequest> _createMultipartRequest(
    List<Multipart> multiparts,
  ) async {
    final request = MultipartRequest(method, uri);
    if (headers.isNotEmpty) request.headers.addAll(headers);
    for (final part in multiparts) {
      if (part.value is Iterable<MultipartFile>) {
        request.files.addAll(part.value);
      } else if (part.value is MultipartFile) {
        request.files.add(part.value);
      } else if (part.isFile) {
        final MultipartFile file;
        if (part.valueIsPath) {
          final filePath = part.value.toString();
          file = await MultipartFile.fromPath(part.fieldName, filePath,
              filename: part.fileName);
        } else {
          if (part.value is Stream<List<int>>) {
            final bytes = await ByteStream(part.value).toBytes();
            file = MultipartFile.fromBytes(part.fieldName, bytes,
                filename: part.fileName);
          } else if (part.value is List<int>) {
            file = MultipartFile.fromBytes(part.fieldName, part.value,
                filename: part.fileName);
          } else {
            file = MultipartFile.fromString(
                part.fieldName, part.value.toString(),
                filename: part.fileName);
          }
        }
        request.files.add(file);
      } else {
        request.fields[part.fieldName] = part.value.toString();
      }
    }
    return request;
  }

  Request _createBodyKnownRequest() {
    final request = Request(method, uri);
    if (headers.isNotEmpty) request.headers.addAll(headers);
    if (body is Map<String, dynamic>) {
      final fieldMap = (body as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
      request.bodyFields = fieldMap;
    } else if (body is List<int>) {
      request.bodyBytes = body;
    } else {
      request.body = body.toString();
    }
    return request;
  }
}
