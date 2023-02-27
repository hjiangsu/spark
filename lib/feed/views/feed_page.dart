import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/enums/front_page_options.dart';
import 'package:spark/feed/widgets/feed_card.dart';
import 'package:spark/singletons/reddit_client.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedBloc>(
      create: (context) => FeedBloc(reddit: RedditClient.instance),
      child: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          switch (state.status) {
            case FeedStatus.initial:
              context.read<FeedBloc>().add(FeedRefreshed(frontPage: FrontPage.popular));
              return Container();
            case FeedStatus.loading:
              return Container();
            case FeedStatus.success:
              return RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    context.read<FeedBloc>().add(FeedRefreshed(subreddit: state.subreddit, frontPage: state.frontPage, category: state.category));
                  },
                  child: ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      return FeedCard(
                        post: state.posts[index],
                        // showExpandedMedia: showExpandedMedia,
                        // index: index,
                      );
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
              return Container();
            case FeedStatus.failure:
              return Container();
            default:
              return Container();
          }
          //   case FeedStatus.initial:
          //     context.read<FeedBloc>().add(FeedRefreshed(getPopular: true));
          //     // return const FeedLoading();
          //   case FeedStatus.failure:
          //     // return FeedError(onRefresh: () async => context.read<FeedBloc>().add(FeedRefreshed(subreddit: null, getHome: state.isHome)));
          //   case FeedStatus.success:
          //     // Update the app bar title's text
          //     widget.onAppBarChanged(appBarTitle: state.displayName ?? '');

          //     return RefreshIndicator(
          //       onRefresh: () async {
          //         HapticFeedback.mediumImpact();
          //         context.read<FeedBloc>().add(FeedRefreshed(
          //               subreddit: state.subreddit,
          //               getHome: state.isHome,
          //               getAll: state.isAll,
          //               getPopular: state.isPopular,
          //               category: categoryOption,
          //             ));
          //       },
          //       child: InViewNotifierList(
          //         addAutomaticKeepAlives: true,
          //         controller: _scrollController,
          //         isInViewPortCondition: (double deltaTop, double deltaBottom, double vpHeight) => deltaTop < (0.7 * vpHeight) && deltaBottom > (0.1 * vpHeight),
          //         itemCount: state.subredditInstance != null ? state.posts.length + 1 : state.posts.length,
          //         builder: (BuildContext context, int index) {
          //           if (index == 0) {
          //             return Column(
          //               children: [
          //                 state.subredditInstance == null ? SearchAutocomplete(searchAll: enableExperimentalFeatures) : subredditDescriptionCard(subreddit: state.subredditInstance),
          //               ],
          //             );
          //           }
          //           return FeedPostCard(
          //             post: state.posts[index - 1],
          //             showExpandedMedia: showExpandedMedia,
          //             index: index - 1,
          //           );
          //         },
          //       ),
          //     );
          //   default:
          //     return FeedLoading(displayName: state.subreddit);
        },
      ),
    );
  }
}
