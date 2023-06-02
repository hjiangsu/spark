import 'dart:async';
import 'dart:ui';

// External package imports
import 'package:html_unescape/html_unescape.dart';
import 'package:reddit/reddit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Spark package imports
import 'package:spark/core/enums/media_type.dart';
import 'package:spark/core/media/extensions/extensions.dart';
import 'package:spark/core/models/media/media.dart';
import 'package:spark/core/models/reddit_comment/reddit_comment.dart';
import 'package:spark/core/media/extensions/imgur_media_extension.dart';
import 'package:spark/core/media/extensions/custom_media_extension.dart';
import 'package:spark/core/media/extensions/reddit_media_extension.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';

/// Parse a submission retrieved from the Reddit library.
Future<RedditSubmission> parseSubmission(Submission submission) async {
  String? url = submission.information["url_overridden_by_dest"];

  // Load up custom media extension if available
  String? customMediaExtensionURL = dotenv.env['CUSTOM_MEDIA_EXTENSION_URL'];

  /// This holds a list of media links associated with the submission
  List<Media>? mediaLinks = [];

  /// Finally, parse the media links
  if (url == null) {
    mediaLinks.add(Media(url: '', mediaType: MediaType.text));
  } else if (RedditMediaExtension.isRedditURL(url)) {
    List<Media> mediaList = await RedditMediaExtension.getMediaInformation(submission);
    mediaLinks.addAll(mediaList);
  } else if (ImgurMediaExtension.isImgurURL(url)) {
    List<Media> mediaList = await ImgurMediaExtension.getMediaInformation(url);
    mediaLinks.addAll(mediaList);
  } else if (CustomMediaExtension.isCustomURL(url, customMediaExtensionURL ?? '')) {
    CustomMediaExtension customMediaExtension = CustomMediaExtension();

    List<Media> mediaList = await customMediaExtension.getMediaInformation(url);
    mediaLinks.addAll(mediaList);
  } else {
    mediaLinks.add(Media(url: url, mediaType: MediaType.link));
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
    video: (mediaLinks.isNotEmpty && mediaLinks.first.mediaType == MediaType.video) ? mediaLinks.first : null,
    image: (mediaLinks.isNotEmpty && mediaLinks.first.mediaType == MediaType.image) ? mediaLinks.first : null,
    text: (mediaLinks.isNotEmpty && mediaLinks.first.mediaType == MediaType.text) ? true : false,
    gallery: (mediaLinks.isNotEmpty && mediaLinks.first.mediaType == MediaType.gallery) ? mediaLinks : null,
    externalLink: (mediaLinks.isNotEmpty && mediaLinks.first.mediaType == MediaType.link) ? mediaLinks.first : null,
    nsfw: submission.information["over_18"] ?? false,
    pinned: submission.information["stickied"] ?? false,
    awardCount: submission.information["gilded"] ?? 0,
    upvoteCount: submission.information["ups"] ?? 0,
    commentCount: submission.information["num_comments"] ?? 0,
    createdAt: submission.information["created_utc"].toInt() ?? 0,
    saved: submission.information["saved"] ?? false,
    upvoted: submission.information["likes"] == true,
    downvoted: submission.information["likes"] == false,
    url: url ?? '',
  );
}

/// Parse a list of comments retrieved from the Reddit library.
dynamic parseComments(List<Comment>? comments, {required String submissionId}) {
  List<RedditComment> redditComments = [];
  if (comments == null) return redditComments;

  for (Comment comment in comments) {
    List<dynamic> children = comment.children ?? [];

    Media? media;

    try {
      // Parse media within the comment
      if (comment.information["media_metadata"] != null) {
        comment.information["media_metadata"].forEach((key, metadata) {
          String url = metadata["s"]["u"] ?? '';
          int mediaWidth = metadata["s"]["x"];
          int mediaHeight = metadata["s"]["y"];

          // Fetch the size dimensions scaled to the current device
          Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

          media = Media(
            url: HtmlUnescape().convert(url),
            width: size.width,
            height: size.height,
            mediaType: MediaType.image,
          );
        });
      }
    } catch (e) {
      print(e);
    }

    redditComments.add(RedditComment(
      id: comment.information["id"],
      authorId: comment.information["author_fullname"] ?? "",
      moderator: comment.information["distinguished"] != null && comment.information["distinguished"] == "moderator",
      subredditId: comment.information["subreddit_id"],
      submissionId: submissionId,
      author: comment.information["author"],
      body: comment.information["body"],
      upvotes: comment.information["ups"],
      createdAt: comment.information["created_utc"].toInt() ?? 0,
      replies: parseComments(comment.replies, submissionId: submissionId),
      children: children,
      media: media,
    ));
  }

  return redditComments;
}
