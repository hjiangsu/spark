part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event to be called when refreshing a post
class PostRefreshed extends PostEvent {
  final String postId;

  PostRefreshed({required this.postId});
}
