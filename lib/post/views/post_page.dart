import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/comment/comment.dart';

import 'package:spark/feed/widgets/post_heading.dart';
import 'package:spark/post/bloc/post_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/widgets/error_message/error_message.dart';
import 'package:spark/widgets/media_view/media_view.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<PostBloc>(
        create: (context) => PostBloc(reddit: RedditClient.instance),
        child: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
          switch (state.status) {
            case PostStatus.initial:
              context.read<PostBloc>().add(PostRefreshed(postId: postId));
              return const Center(child: CircularProgressIndicator());
            case PostStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case PostStatus.success:
              return Scaffold(
                appBar: AppBar(),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PostHeading(post: state.post!),
                            MediaView(post: state.post!),
                          ],
                        ),
                      ),
                      CommentView(
                        submissionId: state.post!.id,
                        subreddit: state.post!.subreddit,
                      ),
                    ],
                  ),
                ),
              );
            case PostStatus.empty:
              return const ErrorMessage(message: 'An error occurred');
            case PostStatus.failure:
              return const ErrorMessage(message: 'An error occurred');
          }
        }));
  }
}