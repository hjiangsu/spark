import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/enums/front_page_options.dart';
import 'package:spark/feed/widgets/feed_card.dart';
import 'package:spark/spark/bloc/spark/spark_bloc.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      context.read<FeedBloc>().add(FeedFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        switch (state.status) {
          case FeedStatus.initial:
            context.read<FeedBloc>().add(FeedRefreshed(frontPage: FrontPage.popular));
            return const Center(child: CircularProgressIndicator());
          case FeedStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case FeedStatus.success:
            context.read<SparkBloc>().add(AppBarTitleChanged(title: state.displayName ?? ''));
            context.read<SparkBloc>().add(const AppBarVisibilityChanged(hideAppBar: false));

            return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  context.read<FeedBloc>().add(FeedRefreshed(subreddit: state.subreddit, frontPage: state.frontPage, category: state.category));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    return FeedCard(post: state.posts[index]);
                    // return FeedPostCard(
                    //   post: state.posts[index - 1],
                    //   // showExpandedMedia: showExpandedMedia,
                    //   index: index - 1,
                    // );
                  },
                )

                // InViewNotifierList(
                //   addAutomaticKeepAlives: true,
                //   controller: _scrollController,
                //   isInViewPortCondition: (double deltaTop, double deltaBottom, double vpHeight) => deltaTop < (0.7 * vpHeight) && deltaBottom > (0.1 * vpHeight),
                //   itemCount: state.subredditInstance != null ? state.posts.length + 1 : state.posts.length,
                //   builder: (BuildContext context, int index) {
                //     if (index == 0) {
                //       return Column(
                //         children: [
                //           state.subredditInstance == null ? SearchAutocomplete(searchAll: enableExperimentalFeatures) : subredditDescriptionCard(subreddit: state.subredditInstance),
                //         ],
                //       );
                //     }
                //     return FeedPostCard(
                //       post: state.posts[index - 1],
                //       showExpandedMedia: showExpandedMedia,
                //       index: index - 1,
                //     );
                //   },
                // ),
                );
          case FeedStatus.empty:
            return const ErrorMessage(message: 'No posts were found');
          case FeedStatus.failure:
            return const ErrorMessage(message: 'Oops, an unexpected error occurred.');
          default:
            return Container();
        }
      },
    );
  }
}
