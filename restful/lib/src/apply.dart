import 'package:meta/meta.dart';
import 'package:reband_restful/reband_restful.dart';

/// Abstraction class for generating an HTTP request of type [T] by [submit],
/// in a sense, this is also the data part wrap for the [T] request.
///
/// The basic role of implemention classes is to create a [T] instance while
/// the [submit] method is invoking, therefore, it can also be regarded as a
/// instantiate factory for request [T].
abstract class Apply<T> {
  static const emptyHeaders = <String, String>{};

  /// The http method used to new a request.
  String get method;

  /// The http uri used to new a request.
  Uri get uri;

  /// The http header map used to new a request.
  Map<String, String> get headers;

  /// The http body used to new a request.
  dynamic get body;

  /// 'Submit' this [Apply] to create a [T] type `Request`, usually it should
  /// be called in your [Reband.launch] implementation to do the real sending
  /// works.
  ///
  /// This is the core method that concrete subclass should implement, which
  /// encapsulate the detail logic for creating [T] by implemented members of
  /// [method], [uri], [headers] and [body].
  Future<T> submit();

  /// Whether current body is type of `Stream<List<int>>`.
  @nonVirtual
  bool get isStreamed => body is Stream<List<int>>;

  /// Whether current body is type of `List<Multipart>`.
  @nonVirtual
  bool get isMultpart => body is List<Multipart>;

  // just making subclasses can have constant constructor.
  const Apply();
}
