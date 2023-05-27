import 'package:flutter/material.dart';

// External package imports
import 'package:reddit/reddit.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Spark package imports
import 'package:spark/core/enums/media_type.dart';
import 'package:spark/core/media/extensions/extensions.dart';
import 'package:spark/core/models/media/media.dart';

abstract class RedditMediaExtension {
  final Submission submission;

  RedditMediaExtension({required this.submission});

  static bool isRedditURL(String url) {
    if (url.contains("v.redd.it") || url.contains("i.redd.it") || url.contains("www.reddit.com/gallery")) {
      return true;
    }

    return false;
  }

  // Parses the reddit URL to determine the media information from it
  static Future<List<Media>> getMediaInformation(Submission submission) async {
    String? url = submission.information["url_overridden_by_dest"];
    if (url == null) throw Exception("Could not fetch Reddit URL");

    List<Media> mediaList = [];

    try {
      if (url.startsWith("https://v.redd.it")) {
        MediaType mediaType = MediaType.video;

        String mediaLink;
        int mediaHeight;
        int mediaWidth;

        if (submission.information["crosspost_parent"] != null) {
          mediaLink = HtmlUnescape().convert(submission.information["crosspost_parent_list"][0]["media"]["reddit_video"]["fallback_url"]);
          mediaHeight = submission.information["crosspost_parent_list"][0]["media"]["reddit_video"]["height"];
          mediaWidth = submission.information["crosspost_parent_list"][0]["media"]["reddit_video"]["width"];
        } else {
          // Fetch information about the video
          mediaLink = HtmlUnescape().convert(submission.information["media"]["reddit_video"]["fallback_url"]);
          mediaHeight = submission.information["media"]["reddit_video"]["height"];
          mediaWidth = submission.information["media"]["reddit_video"]["width"];
        }

        Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

        mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType));
      } else if (url.startsWith("https://i.redd.it")) {
        MediaType mediaType = MediaType.image;

        String mediaLink;
        int mediaHeight;
        int mediaWidth;

        // Check to see if its a gif format, and choose the corresponding video for it if it is
        if (url.endsWith(".gif")) {
          mediaType = MediaType.video;
          // if (submission.information["preview"] != null) {
          // Fetch information about the image if available
          mediaLink = HtmlUnescape().convert(submission.information["preview"]["images"][0]["variants"]["mp4"]["source"]["url"]);
          mediaHeight = submission.information["preview"]["images"][0]["variants"]["mp4"]["source"]["height"];
          mediaWidth = submission.information["preview"]["images"][0]["variants"]["mp4"]["source"]["width"];
          // }
        } else {
          if (submission.information["preview"] != null) {
            // Fetch information about the image if available
            mediaLink = HtmlUnescape().convert(submission.information["preview"]["images"][0]["source"]["url"]);
            mediaHeight = submission.information["preview"]["images"][0]["source"]["height"];
            mediaWidth = submission.information["preview"]["images"][0]["source"]["width"];
          } else {
            // Fetch image information from the image itself
            mediaLink = url;
            ImageInfo imageInfo = await MediaExtension.getImageInfo(Image.network(url));
            mediaHeight = imageInfo.image.height;
            mediaWidth = imageInfo.image.width;
          }
        }

        Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

        mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType));
      } else if (url.startsWith("https://www.reddit.com/gallery/")) {
        MediaType mediaType = MediaType.gallery;

        if (submission.information["crosspost_parent"] != null) {
          submission.information["crosspost_parent_list"][0]["media_metadata"].forEach((key, value) {
            String mediaLink = HtmlUnescape().convert(value["s"]["u"] ?? value["s"]["gif"]);
            double mediaHeight = value["s"]["y"].toDouble();
            double mediaWidth = value["s"]["x"].toDouble();

            // Fetch the size dimensions scaled to the current device
            Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

            mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType, crosspost: true));
          });
        } else {
          submission.information["media_metadata"].forEach((key, value) {
            String mediaLink = HtmlUnescape().convert(value["s"]["u"] ?? value["s"]["gif"]);
            double mediaHeight = value["s"]["y"].toDouble();
            double mediaWidth = value["s"]["x"].toDouble();

            // Fetch the size dimensions scaled to the current device
            Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

            mediaList.add(Media(url: mediaLink, width: size.width, height: size.height, mediaType: mediaType));
          });
        }
      }
    } catch (e, s) {
      Sentry.captureException(e, stackTrace: s);

      // If it fails, fall back to a media type of link
      mediaList.add(Media(url: url, mediaType: MediaType.link));
      return mediaList;
    }

    return mediaList;
  }
}
