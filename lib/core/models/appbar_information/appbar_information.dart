import 'package:flutter/material.dart';

class AppBarInformation {
  AppBarInformation({
    this.title = "",
    this.hidden = false,
    this.actions = const [],
  });

  final String title;
  final bool hidden;
  final List<Widget> actions;
}
