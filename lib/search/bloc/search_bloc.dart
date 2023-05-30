import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:spark/core/enums/search_types.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:reddit/reddit.dart';

part 'search_event.dart';
part 'search_state.dart';

const throttleDuration = Duration(milliseconds: 150);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required this.reddit}) : super(const SearchState()) {
    on<SearchReset>(
      _onSearchReset,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SearchRefreshed>(
      _onSearchRefreshed,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  Future<void> _onSearchReset(SearchReset event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.initial, results: const [], type: event.searchType));
  }

  /// This should be called whenever we want to refresh a search
  Future<void> _onSearchRefreshed(SearchRefreshed event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.loading));

    if (event.query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial, results: const []));
      return;
    }

    try {
      Search search = await reddit.search();

      List<dynamic>? results;

      if (event.searchType == SearchType.subreddit) {
        results = await search.search(subredditQuery: event.query, nsfw: false);
      } else if (event.searchType == SearchType.user) {
        results = await search.search(userQuery: event.query, nsfw: false);
      }

      if (results == null || results.isEmpty) {
        return emit(
          state.copyWith(
            status: SearchStatus.empty,
            type: event.searchType,
            results: [],
          ),
        );
      }

      return emit(
        state.copyWith(
          status: SearchStatus.success,
          type: event.searchType,
          results: results,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: SearchStatus.failure));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
