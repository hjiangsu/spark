import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/enums/search_types.dart';
import 'package:spark/feed/feed.dart';

import 'package:spark/spark/bloc/spark_bloc.dart';
import 'package:spark/search/bloc/search_bloc.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/widgets/error_message/error_message.dart';
import 'package:spark/widgets/submission_badge/submission_badge.dart';

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

  void resetTextField() {
    FocusScope.of(context).unfocus(); // Unfocus the search field
    _controller.clear(); // Clear the search field
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;
    final fontSizeScale = context.read<ThemeBloc>().state.fontSizeScale;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TextField(
            controller: _controller,
            onChanged: (value) => context.read<SearchBloc>().add(SearchRefreshed(query: value, searchType: searchType)),
            decoration: InputDecoration(
              labelText: 'Search for ${searchType == SearchType.user ? 'redditor' : 'subreddit'}',
              // prefixIcon: const Icon(Icons.search),
              suffix: GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  resetTextField();
                  context.read<SearchBloc>().add(SearchRefreshed(query: '', searchType: searchType));
                },
              ),
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
                                  resetTextField(),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            state.results[index].information['display_name_prefixed'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          state.results[index].information['over18'] == true
                                              ? const SubmissionBadge(
                                                  label: 'NSFW',
                                                  fontSize: 10,
                                                  lightThemeColor: Color.fromARGB(255, 248, 194, 190),
                                                  darkThemeColor: Color.fromARGB(255, 160, 53, 45),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
                                      AutoSizeText(
                                        state.results[index].information['public_description'].length > 0 ? state.results[index].information['public_description'] : 'No description available',
                                        maxLines: 2,
                                        minFontSize: theme.textTheme.bodyMedium!.fontSize!,
                                        maxFontSize: theme.textTheme.bodyMedium!.fontSize!,
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
                                  resetTextField(),
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor.withOpacity(0.2))),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: theme.highlightColor,
                                            foregroundImage: CachedNetworkImageProvider(
                                              HtmlUnescape().convert(state.results[index].information['icon_img'] ?? "https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png"),
                                              maxHeight: 64,
                                              maxWidth: 64,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            state.results[index].information['name'],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      state.results[index].information["subreddit"]?['over_18'] == true
                                          ? const Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: SubmissionBadge(
                                                label: 'NSFW',
                                                lightThemeColor: Color.fromARGB(255, 248, 194, 190),
                                                darkThemeColor: Color.fromARGB(255, 160, 53, 45),
                                              ),
                                            )
                                          : Container()
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
    final theme = Theme.of(context);

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
                    searchTypeIcon = Icons.dashboard_rounded;
                    break;
                  case SearchType.user:
                    searchTypeIcon = Icons.people;
                    break;
                  default:
                    break;
                }
              });

              context.read<SearchBloc>().add(SearchReset(searchType: searchType));
              context.read<SparkBloc>().add(AppBarActionChanged(actions: appBarActions()));
              resetTextField();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SearchType>>[
              PopupMenuItem<SearchType>(
                value: SearchType.subreddit,
                child: Row(
                  children: [
                    const Icon(Icons.dashboard_rounded, size: 20.0),
                    const SizedBox(width: 12.0),
                    Text(
                      'Subreddit',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              PopupMenuItem<SearchType>(
                value: SearchType.user,
                child: Row(
                  children: [
                    const Icon(Icons.people, size: 20.0),
                    const SizedBox(width: 12.0),
                    Text(
                      'User',
                      style: theme.textTheme.bodyLarge,
                    ),
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
