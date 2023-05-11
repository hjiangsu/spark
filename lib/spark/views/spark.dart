import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/account/views/account_page.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/search/bloc/search_bloc.dart';
import 'package:spark/search/views/search_page.dart';
import 'package:spark/settings/views/settings_page.dart';
import 'package:spark/spark/bloc/spark_bloc.dart';
import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class Spark extends StatefulWidget {
  const Spark({super.key});

  @override
  State<Spark> createState() => _SparkState();
}

class _SparkState extends State<Spark> {
  int _page = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  void onRouteChange(int pageIndex) {
    if (_page == pageIndex) return;

    setState(() {
      _page = pageIndex;
      _pageController.jumpToPage(pageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(reddit: RedditClient.instance)),
        BlocProvider<FeedBloc>(create: (context) => FeedBloc(reddit: RedditClient.instance)),
        BlocProvider<SearchBloc>(create: (context) => SearchBloc(reddit: RedditClient.instance)),
        BlocProvider<SparkBloc>(create: (context) => SparkBloc()),
      ],
      child: BlocConsumer<SparkBloc, SparkState>(
        listener: (context, state) {
          AppMenu appMenu = state.activePage;

          switch (appMenu) {
            case AppMenu.feed:
              onRouteChange(0);
              break;
            case AppMenu.search:
              onRouteChange(1);
              break;
            case AppMenu.mail:
              onRouteChange(2);
              break;
            case AppMenu.account:
              onRouteChange(3);
              break;
            case AppMenu.settings:
              onRouteChange(4);
              break;
          }
        },
        builder: (context, state) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              switch (state.status) {
                case AuthStatus.initial:
                  context.read<AuthBloc>().add(AuthChecked());
                  return const Center(child: CircularProgressIndicator());
                case AuthStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case AuthStatus.success:
                  return BlocBuilder<SparkBloc, SparkState>(
                    builder: (context, state) {
                      return Scaffold(
                        appBar: state.appBarInformation.hidden
                            ? null
                            : AppBar(
                                toolbarHeight: 70.0,
                                centerTitle: false,
                                title: Text(state.appBarInformation.title, style: theme.textTheme.headlineSmall),
                                actions: state.appBarInformation.actions,
                              ),
                        body: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (int page) {
                            context.read<SparkBloc>().add(const AppBarTitleChanged(title: ''));
                            context.read<SparkBloc>().add(const AppBarActionChanged(actions: []));
                          },
                          children: <Widget>[
                            const FeedPage(),
                            const SearchPage(),
                            Center(child: Container(child: const Text('Messages Page'))),
                            const AccountPage(),
                            const SettingsPage(),
                          ],
                        ),
                        bottomNavigationBar: ActionBar(activePage: _page),
                      );
                    },
                  );
                case AuthStatus.failure:
                  return const ErrorMessage(message: 'An error occurred');
              }
            },
          );
        },
      ),
    );
  }
}
