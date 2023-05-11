import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/spark/spark.dart';

class ActionBar extends StatefulWidget {
  const ActionBar({super.key, this.activePage = 0});

  final int activePage;

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.feed));
          break;
        case 1:
          context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.search));
          break;
        case 2:
          context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.mail));
          break;
        case 3:
          context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.account));
          break;
        case 4:
          context.read<SparkBloc>().add(const ActivePageChanged(appMenu: AppMenu.settings));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomAppBar(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.dashboard_rounded,
              color: (widget.activePage == 0) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: (widget.activePage == 1) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(1),
          ),
          IconButton(
            icon: Icon(
              Icons.mail,
              color: (widget.activePage == 2) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(2),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: (widget.activePage == 3) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(3),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: (widget.activePage == 4) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(4),
          ),
        ],
      ),
    );
  }
}
