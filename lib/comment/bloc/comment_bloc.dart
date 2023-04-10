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

  Future<void> _onCommentFetched(CommentFetched event, Emitter<CommentState> emit) async {
    emit(state.copyWith(status: CommentStatus.fetching, comments: state.comments, children: state.children));

    try {
      // Fetch commentTree, and run more() function
      CommentTree? commentTree = state.commentTree;

      if (commentTree == null) throw Exception('Missing commentTree');
      await commentTree.more(commentId: event.commentId); //jfpe8y1, 14 children

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

  Future<void> _onCommentRefreshed(CommentRefreshed event, Emitter<CommentState> emit) async {
    try {
      dynamic commentTree = await reddit.commentTree(submissionId: event.submissionId.substring(3), subreddit: event.subreddit, commentId: event.commentId);

      // CommentTree commentTree = await reddit.commentTree(submissionId: event.submissionId, subreddit: event.subreddit, commentId: event.commentId);
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
