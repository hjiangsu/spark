part of 'comment_bloc.dart';

enum CommentStatus { initial, loading, fetching, success, empty, failure }

class CommentState extends Equatable {
  const CommentState({
    this.status = CommentStatus.initial,
    this.commentTree,
    this.comments = const [],
    this.children = const [],
  });

  final CommentStatus status;

  final CommentTree? commentTree;
  final List<String> children;
  final List<RedditComment> comments;

  CommentState copyWith({
    required CommentStatus status,
    CommentTree? commentTree,
    List<RedditComment>? comments,
    List<String>? children,
  }) {
    return CommentState(
      status: status,
      commentTree: commentTree ?? this.commentTree,
      comments: comments ?? [],
      children: children ?? [],
    );
  }

  @override
  String toString() => '''CommentState { status: $status }''';

  @override
  List<dynamic> get props => [status];
}
