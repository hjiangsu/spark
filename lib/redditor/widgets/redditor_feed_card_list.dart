import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';

import 'package:spark/feed/widgets/feed_card.dart';
import 'package:spark/redditor/bloc/redditor_bloc.dart';

class RedditorFeedCardList extends StatefulWidget {
  final List<RedditSubmission> posts;
  final bool hasLoadedAllPosts;

  const RedditorFeedCardList({super.key, required this.posts, this.hasLoadedAllPosts = false});

  @override
  State<RedditorFeedCardList> createState() => _RedditorFeedCardListState();
}

class _RedditorFeedCardListState extends State<RedditorFeedCardList> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasLoadedAllPosts && (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent)) {
      context.read<RedditorBloc>().add(RedditorSubmissionsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        context.read<RedditorBloc>().add(RedditorSubmissionsRefreshed());
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length + 1,
        itemBuilder: (context, index) {
          if (index != widget.posts.length) {
            return FeedCard(
              post: widget.posts[index],
              showDivider: index != 0,
            );
          } else {
            return widget.hasLoadedAllPosts
                ? Container()
                : Column(
                    children: [
                      Divider(color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade100),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
          }
        },
      ),
    );
  }
}
