import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/enums/search_types.dart';
import 'package:spark/core/singletons/reddit_client.dart';
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
    _controller = TextEditingController();
    super.initState();
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

    return BlocProvider(
      create: (context) => SearchBloc(reddit: RedditClient.instance),
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 90.0,
              scrolledUnderElevation: 0.0,
              title: SearchBar(
                controller: _controller,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.search_rounded),
                ),
                trailing: [
                  _controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            resetTextField();
                            context.read<SearchBloc>().add(SearchRefreshed(query: '', searchType: searchType));
                          },
                          icon: const Icon(Icons.close),
                        )
                      : IconButton(
                          onPressed: () {
                            if (searchTypeIcon == Icons.dashboard_rounded) {
                              setState(() {
                                searchType = SearchType.user;
                                searchTypeIcon = Icons.people;
                              });
                            } else if (searchTypeIcon == Icons.people) {
                              setState(() {
                                searchType = SearchType.subreddit;
                                searchTypeIcon = Icons.dashboard_rounded;
                              });
                            }
                          },
                          icon: Icon(searchTypeIcon),
                        ),
                ],
                hintText: 'Search for ${searchType == SearchType.subreddit ? 'subreddits' : 'users'}',
                onChanged: (value) => context.read<SearchBloc>().add(SearchRefreshed(query: value, searchType: searchType)),
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                switch (state.status) {
                  case SearchStatus.initial:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.search_rounded, size: 80, color: theme.dividerColor),
                        const SizedBox(height: 10),
                        Text(
                          'Search for subreddits or users',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.dividerColor),
                        )
                      ],
                    );
                  case SearchStatus.loading:
                  case SearchStatus.success:
                    return Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (state.type == SearchType.subreddit) {
                              return InkWell(
                                onTap: () => {
                                  GoRouter.of(context).push('/search/subreddit/${state.results[index].information['display_name']}'),
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(width: 1.0, color: theme.dividerColor.withOpacity(0.2))),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            state.results[index].information['display_name_prefixed'],
                                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          state.results[index].information['over18'] == true
                                              ? const SubmissionBadge(
                                                  label: 'NSFW',
                                                  fontSize: 9,
                                                  lightThemeColor: Color.fromARGB(255, 248, 194, 190),
                                                  darkThemeColor: Color.fromARGB(255, 160, 53, 45),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      AutoSizeText(
                                        state.results[index].information['public_description'].length > 0 ? state.results[index].information['public_description'] : 'No description available',
                                        maxLines: 1,
                                        minFontSize: theme.textTheme.bodySmall!.fontSize!,
                                        maxFontSize: theme.textTheme.bodySmall!.fontSize!,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return InkWell(
                                onTap: () => {
                                  GoRouter.of(context).push('/search/redditor/${state.results[index].information['name']}'),
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
                        ),
                      ),
                    );
                  case SearchStatus.empty:
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ErrorMessage(
                          message: 'No results found',
                          icon: Icons.not_interested_rounded,
                        ),
                      ],
                    );
                  case SearchStatus.failure:
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ErrorMessage(message: 'Oops, an unexpected error occurred.'),
                      ],
                    );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
