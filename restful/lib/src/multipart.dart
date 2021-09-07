class Multipart {
  final String fieldName;
  final dynamic value;
  final String? fileName;
  final bool isValuePath;
  const Multipart(this.fieldName, this.value,
      {this.fileName, this.isValuePath = false});

  bool get isFile => fileName?.isNotEmpty == true || isValuePath;
}
