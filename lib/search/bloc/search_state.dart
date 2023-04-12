part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.type = SearchType.subreddit,
    this.results = const [],
  });

  final SearchStatus status;
  final SearchType type;
  final List<dynamic> results;

  SearchState copyWith({
    required SearchStatus status,
    SearchType? type,
    List<dynamic>? results,
  }) {
    return SearchState(
      status: status,
      type: type ?? this.type,
      results: results ?? [],
    );
  }

  @override
  String toString() => '''SearchState { status: $status results: ${results.length} }''';

  @override
  List<dynamic> get props => [status, results];
}
