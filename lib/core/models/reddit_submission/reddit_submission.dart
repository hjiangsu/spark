import 'package:spark/core/models/media/media.dart';

class RedditSubmission {
  RedditSubmission({
    required this.id,
    required this.authorId,
    required this.subredditId,
    required this.title,
    required this.subreddit,
    required this.description,
    required this.author,
    this.video,
    this.image,
    this.gallery,
    this.externalLink,
    this.text,
    required this.nsfw,
    required this.pinned,
    required this.awardCount,
    required this.upvoteCount,
    required this.commentCount,
    required this.createdAt,
    required this.saved,
    required this.upvoted,
    required this.downvoted,
    required this.url,
  });

  // In this context, the ids are the fullnames of the submission
  String id;
  String authorId;
  String subredditId;

  String title;
  String subreddit;
  String description;
  String author;

  // Content hint for post - contains direct links to any media
  Media? video;
  Media? image;
  List<Media>? gallery;
  Media? externalLink;
  bool? text;

  bool nsfw;
  bool pinned;

  int awardCount;
  int upvoteCount;
  int commentCount;

  int createdAt;

  // Account-authenticated properties
  bool saved;
  bool upvoted;
  bool downvoted;

  String url;
}
