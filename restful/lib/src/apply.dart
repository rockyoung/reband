import 'package:meta/meta.dart';
import 'package:reband_restful/reband_restful.dart';

abstract class Apply<T> {
  static const emptyHeaders = <String, String>{};

  const Apply();

  String get method;
  Uri get uri;
  Map<String, String>? get headers;
  dynamic get body;

  Apply<T> clone({
    String? method,
    Uri? uri,
    Map<String, String>? headers,
    dynamic body,
  });

  /// Submit current `Apply` to create your real `Request`.
  /// Usually it should be called in your reband's launch implementation.
  T submit();

  @nonVirtual
  bool isStreamed() => body is Stream<List<int>>;

  @nonVirtual
  bool isMultpart() => body is List<Multipart>;
}
