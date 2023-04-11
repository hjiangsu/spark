import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spark/core/models/reddit_comment/reddit_comment.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:spark/core/utils/parse.dart';
import 'package:reddit/reddit.dart' hide Comment;

part 'comment_event.dart';
part 'comment_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({required this.reddit}) : super(const CommentState()) {
    on<CommentFetched>(
      _onCommentFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<CommentRefreshed>(
      _onCommentRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  /// Call this function when fetching more comments from either a comment thread, or top-level comments
  Future<void> _onCommentFetched(CommentFetched event, Emitter<CommentState> emit) async {
    emit(state.copyWith(status: CommentStatus.fetching, comments: state.comments, children: state.children));

    try {
      CommentTree? commentTree = state.commentTree;
      if (commentTree == null) throw Exception('Error: Could not obtain commentTree from state');

      // Fetch more comments with the given commentId (if it exists)
      await commentTree.more(commentId: event.commentId);

      // Perform parsing for the new comments
      List<RedditComment> comments = await parseComments(commentTree.comments ?? [], submissionId: event.submissionId);
      List<String> children = List.from(commentTree.moreComments != null ? commentTree.moreComments as Iterable : []);

      return emit(
        state.copyWith(
          status: CommentStatus.success,
          commentTree: commentTree,
          comments: comments,
          children: children,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: CommentStatus.failure, comments: [], children: []));
    }
  }

  /// Call this function when first initializing comments from a submission
  Future<void> _onCommentRefreshed(CommentRefreshed event, Emitter<CommentState> emit) async {
    try {
      CommentTree commentTree = await reddit.commentTree(submissionId: event.submissionId.substring(3), subreddit: event.subreddit, commentId: event.commentId);

      // Perform parsing for the new comments
      List<RedditComment> comments = await parseComments(commentTree.comments ?? [], submissionId: event.submissionId);
      List<String> children = List.from(commentTree.moreComments != null ? commentTree.moreComments as Iterable : []);

      return emit(
        state.copyWith(
          status: CommentStatus.success,
          commentTree: commentTree,
          comments: comments,
          children: children,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: CommentStatus.failure, comments: [], children: []));
    }
  }
}
