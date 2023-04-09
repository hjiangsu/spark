part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CommentFetched extends CommentEvent {}

class CommentRefreshed extends CommentEvent {
  final String? subreddit;
  final String submissionId;
  final String? commentId;

  CommentRefreshed({this.subreddit, required this.submissionId, this.commentId});
}
