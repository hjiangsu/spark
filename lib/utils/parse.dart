import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:reddit/reddit.dart';
import 'package:spark/models/media/media.dart';

import 'package:spark/models/reddit_submission/reddit_submission.dart';

/// Given a width and height, determine the appropriate re-sized dimensions based on the device screen size.
Size _getScaledMediaSize({width, height, offset = 24.0}) {
  double mediaRatio = width / height;

  double widthScale = (MediaQueryData.fromView(WidgetsBinding.instance.window).size.width - offset) / width;
  double mediaMaxWidth = widthScale * width;
  double mediaMaxHeight = mediaMaxWidth / mediaRatio;

  return Size(mediaMaxWidth, mediaMaxHeight);
}

/// Given a url for a valid image, determine the width and height of the image.
Future<Size> _calculateImageDimension(String url) {
  Completer<Size> completer = Completer();
  Image image = Image(image: CachedNetworkImageProvider(url));

  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        dynamic myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );

  return completer.future;
}

Future<RedditSubmission> parseSubmission(Submission submission) async {
  bool isText = false;
  bool isVideo = false;
  bool isImage = false;
  bool isGallery = false;
  bool isExternalLink = false;

  List<Media>? mediaLinks = [];

  // First, determine what type of post this is (image, video, gallery, link, text)
  // @TODO: Add support for handling media types from external urls
  String? overriddenURL = submission.information["url_overridden_by_dest"];

  if (overriddenURL == null) {
    // This is most likely a sign that the post contains only text
    isText = true;
  } else if (overriddenURL.startsWith("https://v.redd.it")) {
    // Handle internal reddit video links
    isVideo = true;

    String mediaLink = submission.information["media"]["reddit_video"]["fallback_url"];
    int originalHeight = submission.information["media"]["reddit_video"]["height"];
    int originalWidth = submission.information["media"]["reddit_video"]["width"];

    Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

    mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
  } else if (overriddenURL.startsWith("https://i.redd.it")) {
    // Handle internal reddit image/media links
    isImage = true;

    String mediaLink = overriddenURL;
    Size imageDimensions = await _calculateImageDimension(overriddenURL);
    double originalHeight = imageDimensions.height;
    double originalWidth = imageDimensions.width;

    Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

    mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
  } else if (overriddenURL.startsWith("https://www.reddit.com/gallery/")) {
    // Handle reddit gallery links
    isGallery = true;

    submission.information["media_metadata"].forEach((key, value) {
      String mediaLink = HtmlUnescape().convert(value["s"]["u"] ?? value["s"]["gif"]);
      int originalHeight = value["s"]["y"];
      int originalWidth = value["s"]["x"];

      Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

      mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
    });
  } else {
    // Handle external links
    isExternalLink = true;
    mediaLinks.add(Media(url: overriddenURL));
  }

  // Generate Post from Submission
  return RedditSubmission(
    id: submission.information["name"] ?? '',
    authorId: submission.information["author_fullname"] ?? '',
    subredditId: submission.information["subreddit_id"] ?? '',
    title: submission.information["title"] ?? '',
    subreddit: submission.information["subreddit"] ?? '',
    description: submission.information["selftext"] ?? '',
    author: submission.information["author"] ?? '',
    video: isVideo ? mediaLinks.first : null,
    image: isImage ? mediaLinks.first : null,
    gallery: isGallery ? mediaLinks : null,
    externalLink: isExternalLink ? mediaLinks.first : null,
    nsfw: submission.information["over_18"] ?? false,
    pinned: submission.information["stickied"] ?? false,
    awardCount: submission.information["gilded"] ?? 0,
    upvoteCount: submission.information["ups"] ?? 0,
    commentCount: submission.information["num_comments"] ?? 0,
    createdAt: submission.information["created_utc"].toInt() ?? 0,
    saved: submission.information["saved"] ?? false,
    upvoted: submission.information["likes"] == true,
    downvoted: submission.information["likes"] == false,
  );
  //   thumbnail: submission.information["thumbnail"],
  //   createdAt: submission.information["created_utc"],
  //   originUrl: url ?? "",
  //   imageURL: imageURL,
  //   videoURL: videoURL,
  //   mediaWidth: mediaWidth,
  //   mediaHeight: mediaHeight,
  //   mediaMaxHeight: mediaMaxHeight,
  //   mediaMaxWidth: mediaMaxWidth,
  //   mediaRatio: mediaRatio,
  //   mediaInformation: mediaInformation,
  // };

  // return submission.information;

  // String? url = submission.information["url"];

  // int? mediaWidth;
  // int? mediaHeight;

  // try {
  //   mediaWidth = submission.information["preview"]["images"][0]["source"]["width"];
  //   mediaHeight = submission.information["preview"]["images"][0]["source"]["height"];
  // } catch (err) {}

  // // Check to see if submission is a video
  // if (submission.information["is_video"] == true) {
  //   try {
  //     // Replace url with the video URL
  //     url = submission.information["media"]["reddit_video"]["fallback_url"];
  //     mediaWidth = submission.information["media"]["reddit_video"]['width'];
  //     mediaHeight = submission.information["media"]["reddit_video"]['height'];
  //   } catch (err) {
  //     throw Exception("Error: no videoURL found for post: ${submission.information["name"]}");
  //   }
  // }

  // // Parse the media information from external sources
  // Map<String, dynamic>? videoInformation = await getVideoInformation(url, client: DioClient.instance);
  // Map<String, dynamic>? imageInformation = await getImageInformation(url, client: DioClient.instance, gfycat: Gfycat(dio: DioClient.instance));

  // String? videoURL;
  // String? imageURL;

  // if (videoInformation != null) {
  //   videoURL = videoInformation['url'];
  //   mediaWidth ??= videoInformation.containsKey('width') ? videoInformation['width'] : null;
  //   mediaHeight ??= videoInformation.containsKey('height') ? videoInformation['height'] : null;
  // }

  // if (imageInformation != null) {
  //   imageURL = imageInformation['url'];
  //   mediaWidth = imageInformation.containsKey('width') ? imageInformation['width'] : mediaWidth;
  //   mediaHeight = imageInformation.containsKey('height') ? imageInformation['height'] : mediaHeight;
  // }

  // // Determine media information for gallery, image, and video
  // Map<String, dynamic> mediaInformation = {};

  // if (submission.information.containsKey("is_gallery") && submission.information["is_gallery"]) {
  //   mediaInformation.putIfAbsent('isGallery', () => true);

  //   Map<String, dynamic> mediaData = submission.information["media_metadata"];
  //   List mediaList = [];

  //   mediaData.forEach((key, value) {
  //     Map<String, dynamic> mediaInstance = {
  //       'url': HtmlUnescape().convert(value["s"]["u"] ?? value["s"]["gif"]),
  //       'width': value["s"]["x"],
  //       'height': value["s"]["y"],
  //     };

  //     mediaList.add(mediaInstance);
  //   });

  //   mediaInformation.putIfAbsent('media', () => mediaList);
  // } else {
  //   mediaInformation.putIfAbsent('isGallery', () => false);
  //   mediaInformation.putIfAbsent('isImage', () => imageURL != null);
  //   mediaInformation.putIfAbsent('isVideo', () => videoURL != null);
  //   List mediaList = [];

  //   Map<String, dynamic> mediaInstance = {
  //     'url': imageURL ?? videoURL,
  //     'width': mediaWidth,
  //     'height': mediaHeight,
  //   };

  //   mediaList.add(mediaInstance);
  //   mediaInformation.putIfAbsent('media', () => mediaList);
  // }

  // // Logic for getting correct media height/width for device
  // double mediaMaxHeight = 200;
  // double mediaMaxWidth = 200;
  // double mediaRatio = 0;

  // if (mediaHeight != null && mediaWidth != null) {
  //   mediaRatio = mediaWidth / mediaHeight;

  //   double widthScale = (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width - 24.0) / mediaWidth;
  //   mediaMaxWidth = widthScale * mediaWidth;
  //   mediaMaxHeight = mediaMaxWidth / mediaRatio;
  // }
}

// parseComments(List<reddit.Comment>? comments) {
//   if (comments == null) return;

//   List<Comment> _comments = [];

//   for (reddit.Comment comment in comments) {
//     print(comment);
//     List<dynamic> _children = comment.children ?? [];

//     _comments.add(Comment(
//       id: comment.information["id"],
//       authorId: comment.information["author_fullname"] ?? "",
//       subredditId: comment.information["subreddit_id"],
//       author: comment.information["author"],
//       body: comment.information["body"],
//       upvotes: comment.information["ups"],
//       createdAt: comment.information["created_utc"],
//       replies: parseComments(comment.replies),
//       children: _children,
//     ));
//   }

//   return _comments;
// }
