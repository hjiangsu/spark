part of 'comment_bloc.dart';

enum CommentStatus { initial, loading, fetching, success, empty, failure }

class CommentState extends Equatable {
  /// Holds the comment state for CommentBloc
  const CommentState({
    this.status = CommentStatus.initial,
    this.commentTree,
    this.comments = const [],
    this.children = const [],
  });

  /// The current status of the CommentBloc
  final CommentStatus status;

  /// The comment tree instance fetched from the Reddit library
  final CommentTree? commentTree;

  /// The remaining top-level comments whose information is yet to be retrieved
  final List<String> children;

  /// A list of comments that have been retrieved from the Reddit library
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
  String toString() => '''CommentState { status: $status, comments: ${comments.length}, children: ${children.length} }''';

  @override
  List<dynamic> get props => [status, commentTree, comments, children];
}
