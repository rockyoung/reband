import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';
import 'http_methods.dart';

/// Define a RESTful API service.
///
/// ```dart
/// @RestfulApi(basePath: '/todos')
/// abstract class TodosListService {
///   // define your endpoints...
/// }
/// ```
@Target({TargetKind.classType})
@sealed
class RESTfulApis {
  // A part of a URL that every request defined inside a class annotated with [RestfulApi] will be prefixed with.
  final String basePath;

  const RESTfulApis({this.basePath = ''});
}

/// Named replacement in a URL path segment.
///
/// Simple example:
/// ```dart
/// @GET('/image/{id}')
/// Future<Response> example(@Path('id') int imageId);
/// ```
/// Calling with
/// ```dart
/// api.example(1);
/// ```
/// yields `/image/1`.
///
/// **Path name should not be blank.**
@Target({TargetKind.parameter})
@sealed
class Path {
  const Path([this.name]);
  final String? name;
}

const path = Path();

/// Because it takes no parameters, annotation should use [queries] instead.
@Target({TargetKind.parameter})
@sealed
class Queries {
  const Queries();
}

/// Query parameter keys and values appended to the URL.
///
/// Simple Example:
/// ```dart
/// @GET('/friends')
/// Future<Response> example(@queries Map<String, dynamic> query);
/// ```
/// Calling with
/// ```dart
/// api.example({'page': [1, 2], 'job': 'manager'});
/// ```
/// yields `/friends?page=1&page=2&job=manager}`.
///
/// also see [Query].
const queries = Queries();

/// Query parameter appended to the URL.
///
/// Simple Example:
/// ```dart
/// @GET('/friends')
/// Future<Response> example(@Query('page') int page);
/// ```
/// Calling with
/// ```dart
/// api.example(1);
/// ```
/// yields `/friends?page=1`.
///
/// also see [Queries].
@Target({TargetKind.parameter})
@sealed
class Query {
  final String? name;

  /// ???
  const Query([this.name]);
}

const query = Query();

/// Add or replace headers literally supplied in the [value].
///
/// Simple Example:
/// ```dart
/// @HeadMap({
///   'Cache-Control': 'max-age=640000',
///   'User-Agent': 'Reband-Client-Engine'
/// })
/// @GET('/foo')
/// Future<Response> bar();
/// ```
///
/// also see [Header], [Headers].
@Target({TargetKind.method})
@sealed
class HeaderMap {
  final Map<String, String> value;
  const HeaderMap(this.value);
}

/// Because it takes no parameters, annotation should use [headers] instead.
@Target({TargetKind.parameter})
@sealed
class Headers {
  const Headers();
}

/// Add or replace the headers specified in the [Map].
///
/// Simple Example:
/// ```dart
/// @GET('/search')
/// Future<Response> list(@headers Map<String, String> headers);
/// ```
///
/// also see [Header], [HeaderMap].
const headers = Headers();

/// Add or replace the header with the value of its target.
///
/// Simple Example:
/// ```dart
/// @GET('/')
/// Future<Response> foo(@Header('Accept-Language') String lang);
/// ```
///
/// also see [Headers], [HeaderMap].
@Target({TargetKind.parameter})
@sealed
class Header {
  final String? name;

  const Header([this.name]);
}

const header = Header();

@Target({TargetKind.parameter})
@sealed
class Fields {
  const Fields();
}

const fields = Fields();

/// Defines a field for a `x-www-form-urlencoded` request.
/// Automatically binds to the name of the method parameter.
///
/// ```dart
/// @Post(path: '/')
/// Future<Response> create(@Field() String name);
/// ```
/// Will be converted to `{ 'name': value }`.
@Target({TargetKind.parameter})
@sealed
class Field {
  final String? name;

  const Field([this.name]);
}

const field = Field();

/// Denotes a single part of a multi-part request.
///
@Target({TargetKind.parameter})
@sealed
class Part {
  /// The name for the form field of part.
  final String? name;

  /// The basename of file for the form file field.
  final String? fileName;

  final bool isFilePath;

  const Part({this.name, this.fileName, this.isFilePath = false});
}

const part = Part();

/// Because it takes no parameters, annotation should use [body] instead.
@Target({TargetKind.parameter})
@sealed
class Body {
  const Body();
}

/// Use this annotation on a service method param when you want to directly
/// control the request body of a [POST], [PUT], and [PATCH] requests (instead
/// of sending in as request parameters or form-style request body).
///
/// Simple Example:
/// ```dart
/// @PUT('/task')
/// Future<Response> example(@body Map<String, dynamic> task);
/// ```
///
/// The body can be of any type, but reband does not automatically convert it to JSON.
/// See [Converter] to apply conversion to the body.
const body = Body();

/// Because it takes no parameters, annotation should use [multipart] instead.
// @Target({TargetKind.method})
// @sealed
// class Multipart {
//   const Multipart();
// }

/// Denotes that the request body is multi-part. Parts should be declared as
/// parameters and annotated with [Part]s.
/// ```dart
/// @multipart
/// @POST('/profile')
/// Future<Response> sync(@Part('description') String desc);
/// ```
// const multipart = Multipart();

// @Target({TargetKind.parameter})
// @sealed
// class PartFile extends Part {

//   const PartFile({String? name, this.fileName}) : super(name);
// }

// const partFile = PartFile();

// @Target({TargetKind.parameter})
// @sealed
// class PartFile {
//   final String? name;

//   const PartFile([this.name]);
// }