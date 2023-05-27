import 'package:spark/core/enums/media_type.dart';

class Media {
  Media({
    required this.url,
    this.width,
    this.height,
    this.mediaType,
    this.token,
    this.crosspost = false,
  });

  String url;
  double? width;
  double? height;
  MediaType? mediaType;
  String? token;
  bool crosspost;

  @override
  String toString() {
    return '''Media { url: $url, width: $width, height: $height }''';
  }
}
