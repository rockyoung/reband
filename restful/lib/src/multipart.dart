class Multipart {
  final String fieldName;
  final dynamic value;
  final String? fileName;
  final bool valueIsPath;
  const Multipart(this.fieldName, this.value,
      {this.fileName, this.valueIsPath = false});

  bool get isFile => fileName?.isNotEmpty == true || valueIsPath;
}
