import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/core/spark/spark.dart';

class ActionBar extends StatefulWidget {
  const ActionBar({super.key});

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class BottomAppBarItem {
  const BottomAppBarItem({required this.initialLocation, required this.icon});

  final String initialLocation;
  final Widget icon;
}

const bottomAppBarItems = [
  BottomAppBarItem(
    initialLocation: '/feed',
    icon: Icon(Icons.dashboard_rounded),
  ),
  BottomAppBarItem(
    initialLocation: '/search',
    icon: Icon(Icons.search),
  ),
  BottomAppBarItem(
    initialLocation: '/mail',
    icon: Icon(Icons.mail),
  ),
  BottomAppBarItem(
    initialLocation: '/account',
    icon: Icon(Icons.person),
  ),
  BottomAppBarItem(
    initialLocation: '/settings',
    icon: Icon(Icons.settings),
  ),
];

class _ActionBarState extends State<ActionBar> {
  int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  // Fetches to corresponding index
  int _locationToTabIndex(String location) {
    final index = bottomAppBarItems.indexWhere((t) => location.startsWith(t.initialLocation));
    return index < 0 ? 0 : index;
  }

  // Callback when a tab is tapped
  void _onItemTapped(BuildContext context, int index) {
    if (index != _currentIndex) {
      GoRouter.of(context).go(bottomAppBarItems[index].initialLocation);
    } else if (index == _currentIndex && index == 0) {
      context.read<SparkBloc>().state.feedScrollController?.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomAppBarWidgets = Row(
      children: bottomAppBarItems.asMap().entries.map((entry) {
        int index = entry.key;
        BottomAppBarItem item = entry.value;

        return IconButton(
          icon: item.icon,
          onPressed: () => _onItemTapped(context, index),
        );
      }).toList(),
    );

    return BottomAppBar(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        bottomAppBarWidgets,
        BlocBuilder<SparkBloc, SparkState>(builder: (context, state) {
          return Text(context.read<SparkBloc>().state.rateLimitUsage.toString());
        }),
      ]),
    );
  }
}
