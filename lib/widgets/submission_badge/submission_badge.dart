import 'package:flutter/material.dart' hide Badge;

import 'package:badges/badges.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/theme/bloc/theme_bloc.dart';

class SubmissionBadge extends StatelessWidget {
  const SubmissionBadge({
    super.key,
    this.label,
    this.icon,
    required this.lightThemeColor,
    required this.darkThemeColor,
  });

  final String? label;
  final Icon? icon;
  final Color lightThemeColor;
  final Color darkThemeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Badge(
      badgeAnimation: const BadgeAnimation.fade(toAnimate: false),
      badgeStyle: BadgeStyle(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: BadgeShape.square,
        badgeColor: useDarkTheme ? darkThemeColor : lightThemeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      badgeContent: (label != null)
          ? Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
            )
          : (icon != null)
              ? icon
              : null,
    );
  }
}
