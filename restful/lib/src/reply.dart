import 'package:meta/meta.dart';

typedef OnGetStatusCode<T> = int Function(T);
typedef OnGetHeaders<T> = Map<String, String> Function(T);
typedef OnGetBody<T> = dynamic Function(T);

abstract class Reply<T> {
  final T rawResponse;
  late final int statusCode = _onGetStatusCode(rawResponse);
  late final Map<String, String> headers = _onGetHeaders(rawResponse);
  late final dynamic body = _onGetBody(rawResponse);

  final OnGetStatusCode<T> _onGetStatusCode;
  final OnGetHeaders<T> _onGetHeaders;
  final OnGetBody<T> _onGetBody;

  Reply(this.rawResponse, this._onGetStatusCode, this._onGetHeaders,
      this._onGetBody);

  /// Returns true if [statusCode] is in the range [200..300).
  @nonVirtual
  late final bool isSuccessful = statusCode >= 200 && statusCode < 300;
}
