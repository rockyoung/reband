import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A wrapper that representing a response of a reband network call, reabstract
/// all `Response` types of different HTTP client.
abstract class Reply {
  /// Total milliseconds time consumed for the HTTP communication, the default
  /// value should be -1.
  int get timeConsumed;

  /// The HTTP status code from this reply wrapped response.
  int get statusCode;

  /// The status message (or reason phrase) associated with the [statusCode].
  String? get message;

  /// The HTTP headers from this reply wrapped response.
  Map<String, String> get headers;

  /// The stream body data from this reply wrapped response.
  Stream<List<int>> get bodyStream;

  /// The body byte data from finished [bodyStream].
  FutureOr<Uint8List> get bodyBytes;

  /// The body as a string decoded from [bodyBytes].
  FutureOr<String> get bodyString;

  /// Whether the wrapped [T] is a successful HTTP response.
  ///
  /// Returns true only if [statusCode] is in the range of [200..300).
  @nonVirtual
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
