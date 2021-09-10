import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';
import '../multipart.dart';
import '../reband_base.dart';
import '../reband_type.dart';

/// Core annotation to make library reband_generat begin to work.
@Target({TargetKind.classType})
@sealed
class RESTfulApis {
  /// An base path that every request defined inside will be prefixed with.
  final String basePath;

  /// Define a RESTful API service with an optional [basePath].
  ///
  /// ```dart
  /// @RESTfulApis(basePath: '/todos')
  /// abstract class TodoListService with RebandService<MyReband> {
  ///   // define your requests...
  /// }
  /// ```
  /// ***IMPORTANT***:
  ///  - target must be an abstract class, as `TodoListService` in the above
  /// example code;
  ///  - target must inherited from [RebandService] with a type param which is
  /// your implementation type of [Reband], no matter what way inherite to.
  const RESTfulApis({this.basePath = ''});
}

/// Named replacement in a URL path segment.
@Target({TargetKind.parameter})
@sealed
class Path {
  /// Replacing name as `{name}`.
  final String? name;

  /// Create a path replacement by optional [name], all '{name}' in the url
  /// will be replaced by string value of the annotating parameter before
  /// annotating queries appended to.
  ///
  /// Simple example:
  /// ```dart
  /// @GET('/{any}/Id_{id}')
  /// Future<MyReply> api(@Path('any') String what, @path int id);
  /// ```
  /// Calling with `example.api('user', 1970);` yields `/user/Id_1970`.
  ///
  /// **NOTE**: The annotated param value should not URL encoded since all of
  /// them will be encoded when building a [Uri] at last.
  ///
  /// The display name of annotated parameter will be used if optinal [name]
  /// is unassigned(`null`), should use const [path] annotation instead of
  /// [Path] in this case, like above example code for the parameter `id`.
  const Path([this.name]);
}

/// Constant instance of [Path] annotation that will use the annotating
/// paramter's name as for it's name.
const path = Path();

/// Query parameter keys and values appended to the URL.
@Target({TargetKind.parameter})
@sealed
class Queries {
  /// Query parameter keys and values appended to the URL.
  ///
  /// Client should always use [queries] instead.
  const Queries();
}

/// Constant [Queries] instance for annotating on a [Map] with [String] keys.
///
/// Simple Examples:
/// ```dart
/// @GET('/enemies?alive=true')
/// Future<MyReply> api0(@queries Map<String, String> filter);
///
/// @GET('/friends')
/// Future<MyReply> api1(@queries Map<String, dynamic> filter);
/// ```
/// Calling with `example.api0({'name': 'Satan', 'class': 'devil'});` yields
/// `/enemies?alive=true&name=Satan&class=devil` (before encode).
///
/// Calling with `example.api1({'page': [1, 2], 'job': 'engineer'});` yields
/// `/friends?page=1&page=2&job=engineer` (before encode).
///
/// see [Query] or [query] for single key/value pair user case.
const queries = Queries();

/// A single query parameter appended to the URL.
@Target({TargetKind.parameter})
@sealed
class Query {
  /// Specified query parameter name.
  final String? name;

  /// Create single query name-value pair appended to the URL by `name=value`.
  ///
  /// Names and values will be URL encoded while building the [Uri] for final
  /// request, so it is unnecessary and should not encoding them in advance.
  ///
  /// Simple Example:
  /// ```dart
  /// @GET('/search')
  /// Future<MyReply> api(@Query('age') int qn0, @query double feet);
  /// ```
  /// Calling with `foo.api(24, 6.4);` yields `/search?age=24&feet=6.4`
  /// (before encode).
  ///
  /// The display name of annotated parameter will be used if optinal [name]
  /// is unassigned(`null`), should use const [query] annotation instead of
  /// [Query] in this case, like above example code for the parameter `feet`.
  /// also see annotation formultiple [queries] by `Map<String, dynamic>`.
  const Query([this.name]);
}

/// Constant instance of [Query] annotation that will use the annotating
/// paramter's name as for it's name.
const query = Query();

/// Add or replace headers literally supplied in the [value].
@Target({TargetKind.method})
@sealed
class HeaderMap {
  final Map<String, String> value;

  /// Supply headers literally in [value] through type `Map<String, String>`,
  /// headers will **overwrite** by the same name.
  ///
  /// Simple Example:
  /// ```dart
  /// @HeadMap({
  ///   'Cache-Control': 'max-age=640000',
  ///   'User-Agent': 'Reband-Client-Engine'
  /// })
  /// @DELETE('/enemy/kill')
  /// Future<MyReply> wipeOut(@query int id);
  /// ```
  /// **NOTE**: This is a method annotation for constant usage, for parameter
  /// annotations, please see [Header] and [headers].
  const HeaderMap(this.value);
}

/// Adds or replace headers specified in a [Map] parameter.
@Target({TargetKind.parameter})
@sealed
class Headers {
  /// Adds or replace headers specified in a [Map] parameter.
  ///
  /// Client should always use [headers] instead.
  const Headers();
}

/// Constant [Headers] instance for annotating on a parameter of [Map] type to
/// add or replace headers.
///
/// Simple Example:
/// ```dart
/// @GET('/bar')
/// Future<MyReply> foo(@headers Map<String, String> headers);
/// ```
/// **NOTE**: The only acceptable map type is `Map<String, String>`.
///
/// also see [Header] and [HeaderMap] annotations.
const headers = Headers();

/// Add or replace the header with the value of its target.
@Target({TargetKind.parameter})
@sealed
class Header {
  /// Header name present in a request, as a 'key' in the final map.
  final String name;

  /// No matter what type of parameter you are annotating on, will always be
  /// converted by [Object.toString].
  ///
  /// Simple Example:
  /// ```dart
  /// @PATCH('/')
  /// Future<MyReply> foo(@Header('Accept-Language') LangEnum lang);
  /// ```
  /// also see [Headers], [HeaderMap].
  const Header(this.name);
}

/// Named key/value pairs for a form-encoded request.
@Target({TargetKind.parameter})
@sealed
class Fields {
  /// Named key/value pairs for a form-encoded request.
  ///
  /// Client should always use [fields] instead.
  const Fields();
}

/// Constant [Fields] instance for annotating on a [Map] with [String] keys.
///
/// Values are converted to strings by [Object.toString].
///
/// Simple Example:
/// ```dart
/// @POST('/things')
/// Future<MyReply> api(@fields Map<String, dynamic> params);
/// ```
/// Calling with `foo.api({'are': 'you', 'ok': 0});` yields a request body of
/// `are=you&ok=0` (before encode).
///
/// see [Field] or [field] for single key/value pair user case.
const fields = Fields();

/// Named single pair for a form-encoded request.
@Target({TargetKind.parameter})
@sealed
class Field {
  /// Field name as a 'key' in the final map.
  final String? name;

  /// Defines a form field for the request by optional [name] and the value of
  /// annotating parameter.
  ///
  /// Simple Example:
  /// ```dart
  /// @POST('/comment/create')
  /// Future<MyReply> createComment(
  ///   @Field('author_id') int authorId,
  ///   @field String content,
  /// );
  /// ```
  /// Calling with `myService.createComment(1024, 'Hey Reband!');` yields a
  /// request body of `author_id=1024&content=Hey Reband!` (before encode).
  ///
  /// Automatically binds to the display name of the annotating parameter if
  /// the optinal [name] is unassigned(`null`), should use constant [field]
  /// annotation in this case, like parameter `content` in example code.
  const Field([this.name]);
}

/// Constant instance of [Field] annotation that will use the annotating
/// paramter's name as for it's name.
const field = Field();

/// Denotes a single part of a multi-part request.
@Target({TargetKind.parameter})
@sealed
class Part {
  /// The name for form field of the part.
  final String? name;

  /// The basename of file for the form file field.
  final String? fileName;

  /// Indicates whether it is a file path.
  final bool isFilePath;

  /// Create a [Multipart] by the optional [name], [fileName] and [isFilePath]
  /// args and the annotating parameter value.
  ///
  /// Simple Example:
  /// ```dart
  /// @POST('/example/create')
  /// Future<MyReply> createSomething(
  ///   @Part(name: 'description') String desc,
  ///   @part Map<String, dynamic> content,
  ///   @Part(fileName: 'image0.jpg') Stream<List<int>> img0,
  ///   @Part(name: 'img1', fileName: 'image1') List<int> bytesImg1,
  ///   @Part(isFilePath: true) String img2,
  ///   @Part(name: 'img3', isFilePath: true) Uri uriImg3,
  ///   @Part(fileName: 'err.log') String log,
  /// );
  /// ```
  const Part({this.name, this.fileName, this.isFilePath = false});
}

/// Constant [Part] annotation instance which `name` will use the annotating
/// paramter's name, while `fileName` is null and `isFilePath` is false.
const part = Part();

/// Annotation used to control the request body directly.
@Target({TargetKind.parameter})
@sealed
class Body {
  /// Annotation used to control the request body directly.
  ///
  /// Client should always use the constant [body] instead.
  const Body();
}

/// Use this annotation on a method parameter when you want to directly control
/// the request body, may need add or replace the right header by this way.
///
/// Simple Example:
/// ```dart
/// @PUT('/task')
/// Future<MyReply> example(@body List<Task> tasks);
/// ```
/// The body can be of any type, but how to process the final body/bodies by
/// it's/their type/types is depending on the engine implementations of this
/// library, in other words it’s TOTALLY up to you.
/// Despite this, the following rules are recommended:
///  - for `Stream<List<int>>`, a "streamed" request should take over.
///  - for `List<Multipart>`, it has been indicated clearly that it is a
/// "multipart" request.
///  - for `Map<String, dynamic>`, "form-encoded" request is the best choice.
///  - for `List<int>`, consider it as the body bytes is a good idea, because
/// if you want it sended as a array string ('[1,2,3...]'), why not just make
/// it's type as [String]?
///  - all other types, should convert to [String] by [Object.toString] for a
/// request body of 'text/plain' content type.
const body = Body();
