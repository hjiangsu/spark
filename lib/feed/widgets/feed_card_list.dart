import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/core/spark/spark.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/enums/category_options.dart';
import 'package:spark/core/enums/front_page_options.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/feed/widgets/feed_card.dart';

class FeedCardList extends StatefulWidget {
  final String? subreddit;
  final FrontPage? frontPage;
  final CategoryOptions? category;
  final List<RedditSubmission> posts;

  const FeedCardList({super.key, this.subreddit, this.frontPage, this.category, required this.posts});

  @override
  State<FeedCardList> createState() => _FeedCardListState();
}

class _FeedCardListState extends State<FeedCardList> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    context.read<SparkBloc>().add(FeedScrollControllerChanged(scrollController: _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    try {
      context.read<SparkBloc>().add(const FeedScrollControllerChanged(scrollController: null));
      _scrollController.dispose();
    } catch (e) {
      print('Unable to dispose on Feed Card List');
    }

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      context.read<FeedBloc>().add(FeedFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        context.read<FeedBloc>().add(FeedRefreshed(
              subreddit: widget.subreddit,
              frontPage: widget.frontPage,
              category: widget.category,
            ));
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length + 1,
        cacheExtent: MediaQuery.of(context).size.height * 1.5,
        itemBuilder: (context, index) {
          if (index != widget.posts.length) {
            return FeedCard(
              post: widget.posts[index],
              showDivider: index != 0,
            );
          } else {
            return Column(
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
