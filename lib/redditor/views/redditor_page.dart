import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/singletons/reddit_client.dart';

import 'package:spark/redditor/bloc/redditor_bloc.dart';
import 'package:spark/redditor/widgets/redditor_feed_card_list.dart';

import 'package:spark/widgets/error_message/error_message.dart';

class RedditorPage extends StatefulWidget {
  final String username;

  const RedditorPage({super.key, required this.username});

  @override
  State<RedditorPage> createState() => _RedditorPageState();
}

class _RedditorPageState extends State<RedditorPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => RedditorBloc(reddit: RedditClient.instance),
      child: BlocBuilder<RedditorBloc, RedditorState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 70.0,
              centerTitle: false,
              title: AutoSizeText(
                widget.username,
                style: theme.textTheme.titleLarge,
              ),
              actions: const [],
            ),
            body: getRedditorSubmissionBody(context, state.status, state),
          );
        },
      ),
    );
  }

  // Determines the feed body based on the status of the RedditorBloc
  Widget getRedditorSubmissionBody(BuildContext context, RedditorStatus status, RedditorState state) {
    switch (state.status) {
      case RedditorStatus.initial:
        context.read<RedditorBloc>().add(RedditorRefeshed(username: widget.username));
        return const Center(child: CircularProgressIndicator());
      case RedditorStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RedditorStatus.fetching:
      case RedditorStatus.success:
        return RedditorFeedCardList(posts: state.posts, hasLoadedAllPosts: state.noMoreSubmissions);
      case RedditorStatus.empty:
        return const ErrorMessage(
          message: 'No posts were found',
          icon: Icons.not_interested_rounded,
        );
      case RedditorStatus.failure:
        return const ErrorMessage(message: 'Oops, an unexpected error occurred.');
      default:
        return Container();
    }
  }
}
