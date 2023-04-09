class Media {
  Media({
    required this.url,
    this.width,
    this.height,
  });

  String url;
  double? width;
  double? height;

  @override
  String toString() {
    return '''Media { url: $url, width: $width, height: $height }''';
  }
}
