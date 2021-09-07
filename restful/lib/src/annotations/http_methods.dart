import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

/// Base abstraction for an HTTP method.
///
/// Built-in implementations are the most frequently used ones:
/// [GET], [POST], [PUT], [PATCH], [DELETE], [OPTIONS] and [HEAD],
/// extends from or implement this to meet special needs if none
/// of above is satisfied.
@immutable
abstract class HttpMethod {
  /// Specific method name for the HTTP request.
  abstract final String name;

  /// A relative path or even endpoint(full) url string.
  final String endPath;

  ///
  const HttpMethod(this.endPath);
}

/// Marke the method as a GET request.
@Target({TargetKind.method})
@sealed
class GET extends HttpMethod {
  @override
  final String name = 'GET';

  const GET([String path = '']) : super(path);
}

const Get = GET();

/// Marke the method as a POST request.
@Target({TargetKind.method})
@sealed
class POST extends HttpMethod {
  @override
  final String name = 'POST';

  const POST([String? path]) : super(path ?? '');
}

const Post = POST();

/// Marke the method as a PUT request.
///
/// Use the [Body] annotation to pass data to send.
@Target({TargetKind.method})
@sealed
class PUT extends HttpMethod {
  @override
  final String name = 'PUT';

  const PUT(String path) : super(path);
}

/// Marke the method as a PATCH request.
///
/// Use the [Body] annotation to pass data to send.
@Target({TargetKind.method})
@sealed
class PATCH extends HttpMethod {
  @override
  final String name = 'PATCH';

  const PATCH(String path) : super(path);
}

/// Marke the method as a DELETE request.
@Target({TargetKind.method})
@sealed
class DELETE extends HttpMethod {
  @override
  final String name = 'DELETE';

  const DELETE(String path) : super(path);
}

/// Marke the method as a OPTIONS request.
@Target({TargetKind.method})
@sealed
class OPTIONS extends HttpMethod {
  @override
  final String name = 'OPTIONS';

  const OPTIONS(String path) : super(path);
}

/// Marke the method as a HEAD request.
@Target({TargetKind.method})
@sealed
class HEAD extends HttpMethod {
  @override
  final String name = 'HEAD';

  const HEAD(String path) : super(path);
}
