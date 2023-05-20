import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/enums/category_options.dart';
import 'package:spark/core/enums/front_page_options.dart';
import 'package:spark/core/singletons/reddit_client.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/feed/widgets/feed_card_list.dart';
import 'package:spark/spark/bloc/spark_bloc.dart';

import 'package:spark/widgets/error_message/error_message.dart';

class FeedPage extends StatefulWidget {
  final String? subreddit;

  const FeedPage({super.key, this.subreddit});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class CategoryOptionItem {
  const CategoryOptionItem({required this.categoryOption, required this.icon, required this.label});

  final CategoryOptions categoryOption;
  final IconData icon;
  final String label;
}

const categoryOptionsItems = [
  CategoryOptionItem(
    categoryOption: CategoryOptions.best,
    icon: Icons.rocket_launch_rounded,
    label: 'Best',
  ),
  CategoryOptionItem(
    categoryOption: CategoryOptions.hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  CategoryOptionItem(
    categoryOption: CategoryOptions.newest,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  CategoryOptionItem(
    categoryOption: CategoryOptions.rising,
    icon: Icons.auto_graph_rounded,
    label: 'Best',
  ),
];

class _FeedPageState extends State<FeedPage> {
  CategoryOptions? categoryOption = CategoryOptions.best;
  IconData categoryIcon = Icons.rocket_launch_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<FeedBloc>(
      create: (context) {
        return FeedBloc(reddit: RedditClient.instance);
      },
      child: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          context.read<SparkBloc>().add(FeedContextChanged(feedContext: context));

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 70.0,
              centerTitle: false,
              title: AutoSizeText(
                state.displayName ?? '',
                style: theme.textTheme.titleLarge,
              ),
              actions: getAppBarActions(context, widget.subreddit == null),
              leading: widget.subreddit == null
                  ? IconButton(
                      onPressed: () => context.read<SparkBloc>().state.scaffoldKey?.currentState!.openDrawer(),
                      icon: const Icon(Icons.menu),
                    )
                  : null,
            ),

            // drawer: widget.subreddit == null ? FeedDrawer(frontPage: state.frontPage ?? FrontPage.home) : null,
            body: getFeedBody(context, state.status, state),
          );
        },
      ),
    );
  }

  // Generates the app bar actions for the feed page
  List<Widget> getAppBarActions(BuildContext context, bool isMainPage) {
    final theme = Theme.of(context);

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isMainPage
              ? InkResponse(
                  radius: 20.0,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<FeedBloc>().add(FeedRefreshed(subreddit: "random"));
                  },
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                  },
                  child: const Icon(Icons.shuffle_rounded),
                )
              : Container(),
          const SizedBox(width: 8.0),
          PopupMenuButton<CategoryOptions>(
            icon: Icon(categoryIcon),
            position: PopupMenuPosition.under,
            initialValue: categoryOption,
            onSelected: (CategoryOptions value) {
              setState(() {
                categoryOption = value;
                categoryIcon = categoryOptionsItems.firstWhere((element) => element.categoryOption == value).icon;
              });

              context.read<FeedBloc>().add(FeedRefreshed(frontPage: context.read<FeedBloc>().state.frontPage, subreddit: context.read<FeedBloc>().state.subreddit, category: categoryOption));
            },
            itemBuilder: (BuildContext context) => categoryOptionsItems
                .map((item) => PopupMenuItem<CategoryOptions>(
                      value: item.categoryOption,
                      child: Row(
                        children: [
                          Icon(item.icon),
                          const SizedBox(width: 12.0),
                          Text(
                            item.label,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(width: 8.0),
        ],
      )
    ];
  }

  // Determines the feed body based on the status of the FeedBloc
  Widget getFeedBody(BuildContext context, FeedStatus status, FeedState state) {
    switch (state.status) {
      case FeedStatus.initial:
        if (widget.subreddit != null) {
          context.read<FeedBloc>().add(FeedRefreshed(subreddit: widget.subreddit));
        } else {
          context.read<FeedBloc>().add(FeedRefreshed(frontPage: FrontPage.popular));
        }
        return const Center(child: CircularProgressIndicator());
      case FeedStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case FeedStatus.success:
        return FeedCardList(
          subreddit: state.subreddit,
          frontPage: state.frontPage,
          category: state.category,
          posts: state.posts,
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
  }
}
