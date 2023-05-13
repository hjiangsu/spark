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

part 'redditor_event.dart';
part 'redditor_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class RedditorBloc extends Bloc<RedditorEvent, RedditorState> {
  RedditorBloc({required this.reddit}) : super(const RedditorState()) {
    on<RedditorSubmissionsFetched>(
      _onRedditorSubmissionsFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<RedditorSubmissionsRefreshed>(
      _onRedditorSubmissionsRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );

    on<RedditorRefeshed>(
      _onRedditorRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  Future<void> _onRedditorRefreshed(RedditorRefeshed event, Emitter<RedditorState> emit) async {
    try {
      Redditor redditor = await reddit.redditor(username: event.username);

      List<Submission> submissions = await redditor.submissions();

      Iterable<Future<RedditSubmission>> postFutures = submissions.map<Future<RedditSubmission>>((post) => parseSubmission(post));
      List<RedditSubmission> posts = await Future.wait(postFutures);

      return emit(
        state.copyWith(
          status: RedditorStatus.success,
          redditorInstance: redditor,
          posts: posts,
          noMoreSubmissions: false,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: RedditorStatus.failure, posts: [], noMoreSubmissions: true));
      Sentry.captureException(e, stackTrace: s);
    }
  }

  Future<void> _onRedditorSubmissionsFetched(RedditorSubmissionsFetched event, Emitter<RedditorState> emit) async {
    try {
      emit(state.copyWith(status: RedditorStatus.fetching, noMoreSubmissions: state.noMoreSubmissions, posts: state.posts));

      List<Submission> submissions = await state.redditorInstance?.moreSubmissions();
      List<RedditSubmission> posts = List.of(state.posts);

      Iterable<Future<RedditSubmission>> postFutures = submissions.map<Future<RedditSubmission>>((post) => parseSubmission(post));
      List<RedditSubmission> newPosts = await Future.wait(postFutures);

      posts.addAll(newPosts);

      return emit(
        state.copyWith(
          status: RedditorStatus.success,
          posts: posts,
          noMoreSubmissions: submissions.isEmpty,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
        status: RedditorStatus.failure,
        posts: [],
        noMoreSubmissions: true,
      ));
      Sentry.captureException(e, stackTrace: s);
    }
  }

  /// This should be called whenever we want to refresh or fetch an initial feed for a redditor
  Future<void> _onRedditorSubmissionsRefreshed(RedditorSubmissionsRefreshed event, Emitter<RedditorState> emit) async {
    emit(state.copyWith(status: RedditorStatus.loading, posts: [], noMoreSubmissions: true));

    try {
      List<Submission> submissions = await state.redditorInstance?.submissions();

      Iterable<Future<RedditSubmission>> postFutures = submissions.map<Future<RedditSubmission>>((post) => parseSubmission(post));
      List<RedditSubmission> posts = await Future.wait(postFutures);

      return emit(
        state.copyWith(
          status: RedditorStatus.success,
          posts: posts,
          noMoreSubmissions: false,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: RedditorStatus.failure, posts: [], noMoreSubmissions: true));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
