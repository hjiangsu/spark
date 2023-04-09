import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/spark/bloc/spark_bloc.dart';
import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class Spark extends StatefulWidget {
  const Spark({super.key});

  @override
  State<Spark> createState() => _SparkState();
}

class _SparkState extends State<Spark> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  void onRouteChange(int pageIndex) {
    setState(() => _pageController.jumpToPage(pageIndex));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(reddit: RedditClient.instance)),
        BlocProvider<FeedBloc>(create: (context) => FeedBloc(reddit: RedditClient.instance)),
        BlocProvider<SparkBloc>(create: (context) => SparkBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
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
                            title: Text(state.appBarInformation.title),
                            actions: state.appBarInformation.actions,
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
                },
              );
            case AuthStatus.failure:
              return const ErrorMessage(message: 'An error occurred');
          }
        },
      ),
    );
  }
}