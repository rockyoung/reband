import 'package:meta/meta.dart';

/// {@template Multipart.document}
/// This class wrapping and holding the data for creating a multipart request.
/// {@endtemplate}
@sealed
class Multipart {
  /// The name of the field in the form header, should be un-encoded.
  /// ```
  /// '''
  /// <boundary separator line> // --<boundary>/r/n
  /// content-disposition: form-data; name=<encode(fieldName)>
  /// '''
  /// ```
  final String fieldName;

  /// Content value of the field after a form header with one empty lines.
  /// It can be either unencoded plain text (will be encoded before send), the
  /// byte stream of a file, or even the file path string (**SHOULD** also
  /// specify the [valueIsPath] to `true`).
  final dynamic value;

  /// The name for the uploading file, after [fieldName] in the form header.
  /// If it is not null or empty, [value] should be treated as file content
  /// (except [valueIsPath] is true at the same time).
  /// ```
  /// '''
  /// <boundary separator line> // --<boundary>/r/n
  /// content-disposition: form-data; name=<fieldName>; filename=<fileName>
  /// '''
  /// ```
  final String? fileName;

  /// Whether the [value] is path string of a file, default is `false`.
  final bool valueIsPath;

  /// {@macro Multipart.document}
  const Multipart(this.fieldName, this.value,
      {this.fileName, this.valueIsPath = false});

  /// Convenient way to determine whether this part is a file.
  bool get isFile => fileName?.isNotEmpty == true || valueIsPath;
}
