import 'package:flutter/material.dart';

import 'package:spark/enums/app_menu_options.dart';

class ActionBar extends StatefulWidget {
  const ActionBar({super.key, required this.onRouteChange});

  final ValueSetter<AppMenu> onRouteChange;

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      switch (index) {
        case 0:
          widget.onRouteChange(AppMenu.feed);
          break;
        case 1:
          widget.onRouteChange(AppMenu.mail);
          break;
        case 2:
          widget.onRouteChange(AppMenu.account);
          break;
        case 3:
          widget.onRouteChange(AppMenu.settings);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IconButton(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
            icon: Icon(
              Icons.dashboard_rounded,
              color: (_selectedIndex == 0) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(0),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
            icon: Icon(
              Icons.mail,
              color: (_selectedIndex == 1) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(1),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
            icon: Icon(
              Icons.person,
              color: (_selectedIndex == 2) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(2),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
            icon: Icon(
              Icons.settings,
              color: (_selectedIndex == 3) ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
    );
  }
}
