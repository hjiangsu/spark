import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:spark/core/enums/front_page_options.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:reddit/reddit.dart';

import 'package:spark/core/utils/parse.dart';
import 'package:spark/core/enums/category_options.dart';

part 'feed_event.dart';
part 'feed_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({required this.reddit}) : super(const FeedState()) {
    on<FeedFetched>(
      _onFeedFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<FeedRefreshed>(
      _onFeedRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  /// Call this function when you want to handle lazy-loading to load more posts from a given feed.
  Future<void> _onFeedFetched(FeedFetched event, Emitter<FeedState> emit) async {
    try {
      List<Submission> submissions = [];

      if (state.frontInstance != null) {
        submissions = await state.frontInstance.more();
      } else if (state.subredditInstance != null) {
        submissions = await state.subredditInstance.more();
      }

      List<RedditSubmission> posts = List.of(state.posts);

      Iterable<Future<RedditSubmission>> postFutures = submissions.map<Future<RedditSubmission>>((post) => parseSubmission(post));
      List<RedditSubmission> newPosts = await Future.wait(postFutures);

      posts.addAll(newPosts);

      return emit(
        state.copyWith(
          status: posts.isNotEmpty ? FeedStatus.success : FeedStatus.empty,
          posts: posts,
          subredditInstance: state.subredditInstance,
          frontInstance: state.frontInstance,
          subreddit: state.subreddit,
          displayName: state.displayName,
          frontPage: state.frontPage,
          category: state.category,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: FeedStatus.failure, posts: []));
      Sentry.captureException(e, stackTrace: s);
    }
  }

  /// This should be called whenever we want to refresh or fetch an initial feed
  Future<void> _onFeedRefreshed(FeedRefreshed event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading, posts: []));

    try {
      Front? front;
      Subreddit? subreddit;
      List<Submission> submissions = [];

      String? displayName;

      switch (event.frontPage) {
        case FrontPage.popular:
          front = await reddit.front("popular");
          displayName = "Popular Posts";

          switch (event.category) {
            case CategoryOptions.best:
            case CategoryOptions.hot:
              submissions = await front.hot();
              break;
            case CategoryOptions.newest:
              submissions = await front.newest();
              break;
            case CategoryOptions.rising:
              submissions = await front.rising();
              break;
            case CategoryOptions.top:
              break;
            default:
              submissions = await front.hot();
              break;
          }
          break;
        case FrontPage.all:
          front = await reddit.front("all");
          displayName = "All Posts";

          switch (event.category) {
            case CategoryOptions.best:
            case CategoryOptions.hot:
              submissions = await front.hot();
              break;
            case CategoryOptions.newest:
              submissions = await front.newest();
              break;
            case CategoryOptions.rising:
              submissions = await front.rising();
              break;
            case CategoryOptions.top:
              break;
            default:
              submissions = await front.hot();
              break;
          }
          break;
        case FrontPage.home:
          front = await reddit.front("home");
          displayName = "Home";

          switch (event.category) {
            case CategoryOptions.best:
              submissions = await front.best();
              break;
            case CategoryOptions.hot:
              submissions = await front.hot();
              break;
            case CategoryOptions.newest:
              submissions = await front.newest();
              break;
            case CategoryOptions.rising:
              submissions = await front.rising();
              break;
            case CategoryOptions.top:
              break;
            default:
              submissions = await front.best();
              break;
          }
          break;
        default:
          subreddit = await reddit.subreddit(event.subreddit!);

          switch (event.category) {
            case CategoryOptions.best:
            case CategoryOptions.hot:
              submissions = await subreddit.hot();
              break;
            case CategoryOptions.newest:
              submissions = await subreddit.newest();
              break;
            case CategoryOptions.rising:
              submissions = await subreddit.rising();
              break;
            case CategoryOptions.top:
              break;
            default:
              submissions = await subreddit.hot();
              break;
          }
          break;
      }

      Iterable<Future<RedditSubmission>> postFutures = submissions.map<Future<RedditSubmission>>((post) => parseSubmission(post));
      List<RedditSubmission> posts = await Future.wait(postFutures);

      String? subredditName = (state.subreddit != event.subreddit) ? event.subreddit : state.subreddit;
      if (event.subreddit == null) {
        subredditName = null;
      } else {
        if (posts.isNotEmpty && event.subreddit!.startsWith('u_')) {
          subredditName = event.subreddit;
        } else {
          subredditName = posts.isNotEmpty ? posts.first.subreddit : event.subreddit;
        }
      }

      return emit(
        state.copyWith(
          status: posts.isNotEmpty ? FeedStatus.success : FeedStatus.empty,
          posts: posts,
          subredditInstance: subreddit,
          frontInstance: front,
          subreddit: subredditName,
          displayName: displayName ?? subredditName,
          frontPage: event.frontPage,
          category: event.category,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: FeedStatus.failure, posts: []));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
