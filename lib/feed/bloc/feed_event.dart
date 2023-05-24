part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event to be called when fetching more items for a feed
class FeedFetched extends FeedEvent {}

/// Event to be called when refreshing a feed
class FeedRefreshed extends FeedEvent {
  final String? subreddit;
  final CategoryOptions? category;
  final FrontPage? frontPage;

  FeedRefreshed({this.subreddit, this.category, this.frontPage});
}

class FeedPostVoted extends FeedEvent {
  final String postId;
  final bool vote;

  FeedPostVoted({required this.postId, required this.vote});
}

class FeedPostSaved extends FeedEvent {
  final String postId;

  FeedPostSaved({required this.postId});
}
