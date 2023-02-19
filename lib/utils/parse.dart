// import 'package:flutter/widgets.dart';
// import 'package:html_unescape/html_unescape.dart';

// import 'package:spark/comment/models/comment.dart';
// import 'package:spark/post/models/post.dart';

import 'package:reddit/reddit.dart';
// import 'package:spark/singletons/dio.dart';
// import 'package:spark/utils/media.dart';

Future<dynamic> parseSubmission(Submission submission) async {
  return submission.information;
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

  // // Generate Post from Submission
  // return {
  //   id: submission.information["id"],
  //   title: submission.information["title"],
  //   subreddit: submission.information["subreddit"],
  //   upvotes: submission.information["ups"],
  //   upvoted: submission.information["likes"],
  //   thumbnail: submission.information["thumbnail"],
  //   createdAt: submission.information["created_utc"],
  //   comments: submission.information["num_comments"],
  //   description: submission.information["selftext"],
  //   author: submission.information["author"],
  //   originUrl: url ?? "",
  //   imageURL: imageURL,
  //   videoURL: videoURL,
  //   mediaWidth: mediaWidth,
  //   mediaHeight: mediaHeight,
  //   mediaMaxHeight: mediaMaxHeight,
  //   mediaMaxWidth: mediaMaxWidth,
  //   mediaRatio: mediaRatio,
  //   mediaInformation: mediaInformation,
  //   nsfw: submission.information["over_18"],
  //   saved: submission.information["saved"] ?? false,
  //   pinned: submission.information["stickied"] ?? false,
  // };
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
