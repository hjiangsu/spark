import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spark/enums/front_page_options.dart';
import 'package:spark/models/reddit_submission/reddit_submission.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:reddit/reddit.dart';

import 'package:spark/utils/parse.dart';
import 'package:spark/enums/category_options.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.reddit}) : super(const PostState()) {
    on<PostRefreshed>(
      _onPostRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  /// This should be called whenever we want to refresh or fetch an initial post
  Future<void> _onPostRefreshed(PostRefreshed event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostStatus.loading));

    try {
      Submission submission = await reddit.submission(event.postId.substring(3));
      RedditSubmission post = await parseSubmission(submission);

      print(post.id);
      return emit(
        state.copyWith(
          status: PostStatus.success,
          post: post,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }
}
