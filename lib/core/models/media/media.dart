import 'package:spark/core/enums/media_type.dart';

/// The Media class represents information for a given media source.
class Media {
  Media({
    this.url,
    this.originalURL,
    this.width,
    this.height,
    this.mediaType,
    this.token,
    this.crosspost = false,
  });

  /// The original URL of the media - this applies if the original URL of the media originates from a external link
  String? originalURL;

  /// The URL indicates the source of the media
  String? url;

  /// The width of the media source
  double? width;

  /// The height of the media source
  double? height;

  /// Indicates the type of media it holds
  MediaType? mediaType;

  /// Contains the authentication token (if any) to access the media source
  String? token;

  /// Indicates whether the media is part of a crosspost
  bool crosspost;

  @override
  String toString() {
    return '''Media { url: $url, width: $width, height: $height, type: $mediaType, crosspost: $crosspost }''';
  }
}
