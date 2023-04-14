import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:imgur/imgur.dart';

import 'package:reddit/reddit.dart';
import 'package:spark/core/models/media/media.dart';
import 'package:spark/core/models/reddit_comment/reddit_comment.dart';

import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/core/singletons/imgur_client.dart';

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

  try {
    Image image = Image(
      image: CachedNetworkImageProvider(
        url,
        errorListener: () {
          Size size = const Size(0, 0);
          completer.completeError(size);
        },
      ),
    );

    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          dynamic myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          if (completer.isCompleted == false) completer.complete(size);
        },
      ),
    );
  } catch (e) {
    print(e);
  }

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
    try {
      // Handle internal reddit image/media links
      isImage = true;

      String mediaLink = overriddenURL;
      Size imageDimensions = await _calculateImageDimension(overriddenURL);
      double originalHeight = imageDimensions.height;
      double originalWidth = imageDimensions.width;

      Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

      mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
    } catch (e) {
      isImage = false; // Reset this to false since we encountered an error
      print(e);
    }
  } else if (overriddenURL.startsWith("https://www.reddit.com/gallery/")) {
    try {
      // Handle reddit gallery links
      isGallery = true;

      submission.information["media_metadata"].forEach((key, value) {
        String mediaLink = HtmlUnescape().convert(value["s"]["u"] ?? value["s"]["gif"]);
        int originalHeight = value["s"]["y"];
        int originalWidth = value["s"]["x"];

        Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

        mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
      });
    } catch (e) {
      isGallery = false; // Reset this to false since we encountered an error
      print(e);
    }
  } else {
    // Handle special cases
    if (overriddenURL.contains("imgur.com")) {
      try {
        // Use imgur API to get image information
        Imgur imgur = ImgurClient.instance;
        ImgurImage image = await imgur.image(url: overriddenURL);

        String mediaType = image.information!["type"];
        print(image.information!["type"]);

        if (mediaType.contains('mp4')) {
          isVideo = true;
        } else {
          isImage = true;
        }

        String mediaLink = image.information!["link"];
        double originalHeight = image.information!["height"].toDouble();
        double originalWidth = image.information!["width"].toDouble();

        Size size = _getScaledMediaSize(width: originalWidth, height: originalHeight);

        mediaLinks.add(Media(url: mediaLink, width: size.width, height: size.height));
      } catch (e) {
        print(e);
      }
    } else {
      // Handle external links
      isExternalLink = true;
      mediaLinks.add(Media(url: overriddenURL));
    }
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
    text: isText ? true : null,
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
}

dynamic parseComments(List<Comment>? comments, {required String submissionId}) {
  List<RedditComment> _comments = [];
  if (comments == null) return _comments;

  for (Comment comment in comments) {
    List<dynamic> _children = comment.children ?? [];

    _comments.add(RedditComment(
      id: comment.information["id"],
      authorId: comment.information["author_fullname"] ?? "",
      subredditId: comment.information["subreddit_id"],
      submissionId: submissionId,
      author: comment.information["author"],
      body: comment.information["body"],
      upvotes: comment.information["ups"],
      createdAt: comment.information["created_utc"].toInt() ?? 0,
      replies: parseComments(comment.replies, submissionId: submissionId),
      children: _children,
    ));
  }

  return _comments;
}
