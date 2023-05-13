part of 'redditor_bloc.dart';

abstract class RedditorEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RedditorSubmissionsFetched extends RedditorEvent {}

class RedditorSubmissionsRefreshed extends RedditorEvent {}

class RedditorRefeshed extends RedditorEvent {
  final String username;

  RedditorRefeshed({required this.username});
}
