import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/core/enums/category_options.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/core/enums/front_page_options.dart';
import 'package:spark/feed/widgets/feed_card.dart';
import 'package:spark/spark/bloc/spark_bloc.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController(initialScrollOffset: 0);

  CategoryOptions? categoryOption = CategoryOptions.best;
  IconData categoryIcon = Icons.rocket_launch_rounded;

  @override
  void initState() {
    print('helllloo');
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
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

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
            context.read<SparkBloc>().add(AppBarActionChanged(actions: appBarActions()));
            return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  context.read<FeedBloc>().add(FeedRefreshed(subreddit: state.subreddit, frontPage: state.frontPage, category: state.category));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index != state.posts.length) {
                      return FeedCard(post: state.posts[index]);
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
            return const ErrorMessage(
              message: 'No posts were found',
              icon: Icons.not_interested_rounded,
            );
          case FeedStatus.failure:
            return const ErrorMessage(message: 'Oops, an unexpected error occurred.');
          default:
            return Container();
        }
      },
    );
  }

  List<Widget> appBarActions() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              context.read<FeedBloc>().add(FeedRefreshed(frontPage: FrontPage.popular));
            },
            icon: const Icon(Icons.home_rounded),
          ),
          const SizedBox(width: 8.0),
          InkResponse(
            radius: 20.0,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<FeedBloc>().add(FeedRefreshed(subreddit: "random"));
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
            },
            child: const Icon(Icons.shuffle_rounded),
          ),
          const SizedBox(width: 8.0),
          PopupMenuButton<CategoryOptions>(
            icon: Icon(categoryIcon),
            position: PopupMenuPosition.under,
            initialValue: categoryOption,
            onSelected: (CategoryOptions value) {
              setState(() {
                categoryOption = value;

                switch (categoryOption) {
                  case CategoryOptions.best:
                    categoryIcon = Icons.rocket_launch_rounded;
                    break;
                  case CategoryOptions.hot:
                    categoryIcon = Icons.local_fire_department_rounded;
                    break;
                  case CategoryOptions.newest:
                    categoryIcon = Icons.auto_awesome_rounded;
                    break;
                  case CategoryOptions.rising:
                    categoryIcon = Icons.auto_graph_rounded;
                    break;
                  default:
                    break;
                }
              });

              context.read<FeedBloc>().add(FeedRefreshed(
                    frontPage: context.read<FeedBloc>().state.frontPage,
                    subreddit: context.read<FeedBloc>().state.subreddit,
                    category: categoryOption,
                  ));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CategoryOptions>>[
              const PopupMenuItem<CategoryOptions>(
                value: CategoryOptions.best,
                child: Row(
                  children: [
                    Icon(Icons.rocket_launch_rounded, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('Best'),
                  ],
                ),
              ),
              const PopupMenuItem<CategoryOptions>(
                value: CategoryOptions.hot,
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('Hot'),
                  ],
                ),
              ),
              const PopupMenuItem<CategoryOptions>(
                value: CategoryOptions.newest,
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('New'),
                  ],
                ),
              ),
              const PopupMenuItem<CategoryOptions>(
                value: CategoryOptions.rising,
                child: Row(
                  children: [
                    Icon(Icons.auto_graph_rounded, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('Rising'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8.0),
        ],
      )
    ];
  }
}
