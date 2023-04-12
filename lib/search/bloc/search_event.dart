part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchReset extends SearchEvent {
  final SearchType searchType;

  SearchReset({this.searchType = SearchType.subreddit});
}

/// Event to be called when refreshing a search
class SearchRefreshed extends SearchEvent {
  final String query;
  final SearchType searchType;

  SearchRefreshed({required this.query, this.searchType = SearchType.subreddit});
}
