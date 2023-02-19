part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, empty, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.subreddit,
    this.displayName,
    this.frontInstance,
    this.subredditInstance,
    this.frontPage,
    this.category = CategoryOptions.best,
    this.posts = const <dynamic>[],
  });

  final FeedStatus status;
  final List<dynamic> posts;

  final dynamic subredditInstance;
  final dynamic frontInstance;

  final String? subreddit;
  final String? displayName;

  final FrontPage? frontPage;
  final CategoryOptions category;

  FeedState copyWith({
    required FeedStatus status,
    required List<dynamic> posts,
    dynamic subredditInstance,
    dynamic frontInstance,
    String? subreddit,
    String? displayName,
    FrontPage? frontPage,
    CategoryOptions? category,
  }) {
    return FeedState(
      status: status,
      posts: posts,
      subredditInstance: subredditInstance,
      frontInstance: frontInstance,
      subreddit: subreddit,
      displayName: displayName,
      frontPage: frontPage,
      category: category ?? this.category,
    );
  }

  @override
  String toString() =>
      '''FeedState { status: $status, posts: ${posts.length}, subredditInstance: ${subredditInstance == null}, frontInstance: ${frontInstance == null}, subreddit: $subreddit, displayName: $displayName }''';

  @override
  List<dynamic> get props => [status, posts, subredditInstance, frontInstance, subreddit, displayName, frontPage, category];
}
