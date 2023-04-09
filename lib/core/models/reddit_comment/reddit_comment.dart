import 'package:spark/core/models/media/media.dart';

class RedditComment {
  RedditComment({
    required this.id,
    required this.authorId,
    required this.subredditId,
    required this.body,
    required this.author,
    required this.upvotes,
    required this.createdAt,
    this.replies = const [],
    this.children = const [],
  });

  // In this context, the ids are the fullnames of the submission
  String id;
  String authorId;
  String subredditId;

  String body;
  String author;

  dynamic replies;
  dynamic children;

  int upvotes;
  int createdAt;
}
