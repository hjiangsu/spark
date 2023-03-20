part of 'post_bloc.dart';

enum PostStatus { initial, loading, success, empty, failure }

class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.post,
  });

  final PostStatus status;
  final RedditSubmission? post;

  PostState copyWith({
    required PostStatus status,
    RedditSubmission? post,
  }) {
    return PostState(status: status, post: post);
  }

  @override
  String toString() => '''PostState { status: $status }''';

  @override
  List<dynamic> get props => [status];
}
