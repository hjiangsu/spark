import 'package:flutter/material.dart';

import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';

// const tabs = [
//   ScaffoldWithNavBarTabItem(
//     initialLocation: '/a',
//     icon: Icon(Icons.home),
//     label: 'Section A',
//   ),
//   ScaffoldWithNavBarTabItem(
//     initialLocation: '/b',
//     icon: Icon(Icons.settings),
//     label: 'Section B',
//   ),
// ];

class ScaffoldNavBar extends StatefulWidget {
  const ScaffoldNavBar({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<ScaffoldNavBar> createState() => _ScaffoldNavBarState();
}

class _ScaffoldNavBarState extends State<ScaffoldNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: ActionBar(),
    );
  }
}
