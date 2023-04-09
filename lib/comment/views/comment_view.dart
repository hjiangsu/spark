// This will host the view for the comments whenever it is part of another view
// For example: PostPage, CommentPage

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/comment/bloc/comment_bloc.dart';
import 'package:spark/comment/widgets/comment_card.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class CommentView extends StatelessWidget {
  final String? subreddit;
  final String submissionId;
  final String? commentId;

  const CommentView({super.key, required this.submissionId, this.commentId, this.subreddit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentBloc>(
      create: (context) => CommentBloc(reddit: RedditClient.instance),
      child: BlocBuilder<CommentBloc, CommentState>(builder: (context, state) {
        switch (state.status) {
          case CommentStatus.initial:
            context.read<CommentBloc>().add(CommentRefreshed(submissionId: submissionId, subreddit: subreddit, commentId: commentId));
            return const Center(child: CircularProgressIndicator());
          case CommentStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case CommentStatus.success:
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return CommentCard(comment: state.comments[index]);
              },
              itemCount: state.comments.length,
            );
          case CommentStatus.empty:
            return const ErrorMessage(message: 'An error occurred');
          case CommentStatus.failure:
            return const ErrorMessage(message: 'An error occurred');
        }
      }),
    );
  }
}
