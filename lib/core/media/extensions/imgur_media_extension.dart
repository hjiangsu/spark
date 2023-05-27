import 'dart:ui';

// External package imports
import 'package:imgur/imgur.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Spark package imports
import 'package:spark/core/enums/media_type.dart';
import 'package:spark/core/models/media/media.dart';
import 'package:spark/core/singletons/imgur_client.dart';
import 'package:spark/core/media/extensions/extensions.dart';

abstract class ImgurMediaExtension {
  final String url;

  ImgurMediaExtension({required this.url});

  static bool isImgurURL(String url) {
    return url.contains("imgur.com");
  }

  // Parses the Imgur URL to determine the media information from it
  static Future<List<Media>> getMediaInformation(String url) async {
    List<Media> mediaList = [];
    MediaType mediaType;

    Imgur imgur = ImgurClient.instance;

    try {
      ImgurImage image = await imgur.image(url: url);

      String type = image.information!["type"];

      if (type.contains('mp4')) {
        mediaType = MediaType.video;
      } else {
        mediaType = MediaType.image;
      }

      String mediaLink = image.information!["link"];
      int mediaHeight = image.information!["height"];
      int mediaWidth = image.information!["width"];

      Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

      mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType));

      return mediaList;
    } catch (e, s) {
      Sentry.captureException(e, stackTrace: s);

      // If it fails, fall back to a media type of link
      mediaList.add(Media(url: url, mediaType: MediaType.link));
      return mediaList;
    }
  }
}
