import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/enums/search_types.dart';
import 'package:spark/feed/feed.dart';

import 'package:spark/spark/bloc/spark_bloc.dart';
import 'package:spark/search/bloc/search_bloc.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();

  SearchType searchType = SearchType.subreddit;
  IconData searchTypeIcon = Icons.dashboard_rounded;

  @override
  void initState() {
    super.initState();

    context.read<SparkBloc>().add(const AppBarTitleChanged(title: 'Global Search'));
    context.read<SparkBloc>().add(AppBarActionChanged(actions: appBarActions()));
    context.read<SearchBloc>().add(SearchReset()); // Reset the search

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: _controller,
            onChanged: (value) => context.read<SearchBloc>().add(SearchRefreshed(query: value)),
            decoration: InputDecoration(
              labelText: 'Search for ${searchType == SearchType.user ? 'redditor' : 'subreddit'}',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case SearchStatus.initial:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 80,
                              color: theme.dividerColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Search for subreddits or users',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.dividerColor,
                              ),
                            )
                          ],
                        );
                      case SearchStatus.loading:
                      case SearchStatus.success:
                        context.read<SparkBloc>().add(AppBarActionChanged(actions: appBarActions()));

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (state.type == SearchType.subreddit) {
                              return InkWell(
                                onTap: () => {
                                  context.read<FeedBloc>().add(FeedRefreshed(subreddit: state.results[index].information['display_name'])),
                                  context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.feed)),
                                  FocusScope.of(context).unfocus(), // Unfocus the search field
                                  _controller.clear(), // Clear the search field
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor.withOpacity(0.2))),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.results[index].information['display_name_prefixed'],
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4.0),
                                      AutoSizeText(
                                        state.results[index].information['public_description'].length > 0 ? state.results[index].information['public_description'] : 'No description available',
                                        maxLines: 2,
                                        minFontSize: 14.0,
                                        maxFontSize: 14.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return InkWell(
                                onTap: () => {
                                  context.read<FeedBloc>().add(FeedRefreshed(subreddit: state.results[index].information["subreddit"]['display_name'])),
                                  context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.feed)),
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor.withOpacity(0.2))),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.results[index].information['name'],
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          itemCount: state.results.length,
                        );
                      case SearchStatus.empty:
                        return const ErrorMessage(
                          message: 'No results found',
                          icon: Icons.not_interested_rounded,
                        );
                      case SearchStatus.failure:
                        return const ErrorMessage(message: 'Oops, an unexpected error occurred.');
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  List<Widget> appBarActions() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PopupMenuButton<SearchType>(
            icon: Icon(searchTypeIcon),
            position: PopupMenuPosition.under,
            initialValue: searchType,
            onSelected: (SearchType value) {
              setState(() {
                searchType = value;

                switch (searchType) {
                  case SearchType.subreddit:
                    searchTypeIcon = Icons.rocket_launch_rounded;
                    break;
                  case SearchType.user:
                    searchTypeIcon = Icons.people;
                    break;
                  default:
                    break;
                }
              });

              context.read<SearchBloc>().add(SearchReset(searchType: searchType));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SearchType>>[
              const PopupMenuItem<SearchType>(
                value: SearchType.subreddit,
                child: Row(
                  children: [
                    Icon(Icons.dashboard_rounded, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('Subreddit'),
                  ],
                ),
              ),
              const PopupMenuItem<SearchType>(
                value: SearchType.user,
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20.0),
                    SizedBox(width: 12.0),
                    Text('User'),
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
