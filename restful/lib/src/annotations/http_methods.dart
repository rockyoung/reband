import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// Base abstraction for an HTTP method.
///
/// The built-in implementations are the most frequently used ones:
///
/// [GET], [POST], [PUT], [PATCH], [DELETE], [HEAD] and [OPTIONS].
///
/// 'CONNECT' and 'TRACE' or even more special methods can be implemented by
/// inheriting this to meet your needs.
@immutable
abstract class HttpMethod {
  /// Specific method name for the HTTP request.
  abstract final String name;

  /// A relative path or full url of the endpoint.
  final String endPath;

  const HttpMethod(this.endPath);
}

/// Marke the method as a GET request.
@Target({TargetKind.method})
@sealed
class GET extends HttpMethod {
  @override
  final String name = 'GET';

  /// Make a GET request with optional end [path].
  ///
  /// [Get] is prefered if no [path] needed.
  const GET([String path = '']) : super(path);
}

/// Marke the method as a POST request.
@Target({TargetKind.method})
@sealed
class POST extends HttpMethod {
  @override
  final String name = 'POST';

  /// Make a POST request with optional end [path].
  ///
  /// [Post] is prefered if no [path] needed.
  const POST([String? path]) : super(path ?? '');
}

/// Marke the method as a PUT request.
@Target({TargetKind.method})
@sealed
class PUT extends HttpMethod {
  @override
  final String name = 'PUT';

  /// Make a PUT request with end [path].
  const PUT(String path) : super(path);
}

/// Marke the method as a PATCH request.
@Target({TargetKind.method})
@sealed
class PATCH extends HttpMethod {
  @override
  final String name = 'PATCH';

  /// Make a PATCH request with end [path].
  const PATCH(String path) : super(path);
}

/// Marke the method as a DELETE request.
@Target({TargetKind.method})
@sealed
class DELETE extends HttpMethod {
  @override
  final String name = 'DELETE';

  /// Make a DELETE request with end [path].
  const DELETE(String path) : super(path);
}

/// Marke the method as a HEAD request.
@Target({TargetKind.method})
@sealed
class HEAD extends HttpMethod {
  @override
  final String name = 'HEAD';

  /// Make a HEAD request with end [path].
  const HEAD(String path) : super(path);
}

/// Marke the method as a OPTIONS request.
@Target({TargetKind.method})
@sealed
class OPTIONS extends HttpMethod {
  @override
  final String name = 'OPTIONS';

  /// Make a OPTIONS request with end [path].
  const OPTIONS(String path) : super(path);
}

/// Constant [GET] annotation with default empty 'path'.
const Get = GET();

/// Constant [POST] annotation with default empty 'path'.
const Post = POST();
