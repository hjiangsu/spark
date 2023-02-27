import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:pubnub/pubnub.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/enums/app_menu_options.dart';
// import 'package:spark/account/account.dart';
// import 'package:spark/settings/settings.dart';
import 'package:spark/auth/bloc/auth_bloc.dart';
import 'package:spark/singletons/reddit_client.dart';
import 'package:spark/theme/theme.dart';
import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';

class Spark extends StatefulWidget {
  const Spark({super.key});

  @override
  State<Spark> createState() => _SparkState();
}

class _SparkState extends State<Spark> {
  final PageController _pageController = PageController(initialPage: 0);

  // App Bar
  List<Widget> _appBarActions = [];
  String? _appBarTitle;

  // Hiding scaffold elements
  bool _hideAppBar = false;

  @override
  void initState() {
    super.initState();
  }

  /// Generates a Text widget based on the appBarTitle
  Widget getAppBarTitle() {
    return AutoSizeText(_appBarTitle ?? "", maxLines: 1);
  }

  void onRouteChange(int pageIndex) {
    setState(() => _pageController.jumpToPage(pageIndex));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(reddit: RedditClient.instance),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
              context.read<AuthBloc>().add(AuthChecked());
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.success:
              return Scaffold(
                appBar: _hideAppBar == true
                    ? null
                    : AppBar(
                        toolbarHeight: 70.0,
                        centerTitle: false,
                        title: getAppBarTitle(),
                        actions: [
                          // this theme changer is temporary
                          IconButton(
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              bool useDarkTheme = prefs.getBool('useDarkTheme') ?? true;
                              await prefs.setBool('useDarkTheme', !useDarkTheme);
                              context.read<ThemeBloc>().add(ThemeRefreshed());
                            },
                            icon: const Icon(Icons.dark_mode_outlined),
                          ),
                        ],
                      ),
                body: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const FeedPage(),
                    Center(child: Container(child: const Text('Messages Page'))),
                    Center(child: Container(child: const Text('Account Page'))),
                    Center(child: Container(child: const Text('Settings Page')))
                  ],
                ),
                bottomNavigationBar: ActionBar(onRouteChange: (AppMenu menu) => onRouteChange(menu.index)),
              );
            case AuthStatus.failure:
              // @TODO - Make a widget to hold generic error message
              return const Center(child: Text("An error occurred"));
          }
        },
      ),
    );
  }
}
