part of 'redditor_bloc.dart';

enum RedditorStatus { initial, loading, fetching, success, empty, failure }

class RedditorState extends Equatable {
  const RedditorState({
    this.status = RedditorStatus.initial,
    this.redditorInstance,
    this.posts = const <RedditSubmission>[],
    this.noMoreSubmissions = false,
  });

  final RedditorStatus status;
  final Redditor? redditorInstance;
  final List<RedditSubmission> posts;
  final bool noMoreSubmissions;

  RedditorState copyWith({
    required RedditorStatus status,
    Redditor? redditorInstance,
    required List<RedditSubmission> posts,
    required bool noMoreSubmissions,
  }) {
    return RedditorState(
      status: status,
      redditorInstance: redditorInstance ?? this.redditorInstance,
      posts: posts,
      noMoreSubmissions: noMoreSubmissions,
    );
  }

  @override
  String toString() => '''RedditorState { status: $status, posts: ${posts.length} }''';

  @override
  List<dynamic> get props => [status, posts];
}
