import 'package:meta/meta.dart';

abstract class Reply<T> {
  final T rawResponse;
  final int timeConsuming;

  int get statusCode;
  String? get message;
  Map<String, String> get headers;

  Stream<List<int>> get bodyStream;
  // Future<List<int>> get bodyBytes;
  // Future<String> get bodyString;

  const Reply(this.rawResponse, this.timeConsuming);

  /// Returns true if [statusCode] is in the range [200..300).
  @nonVirtual
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
