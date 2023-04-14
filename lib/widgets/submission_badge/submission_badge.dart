import 'package:flutter/material.dart' hide Badge;

import 'package:badges/badges.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';

class SubmissionBadge extends StatelessWidget {
  const SubmissionBadge({
    super.key,
    this.label,
    this.icon,
    this.fontSize,
    required this.lightThemeColor,
    required this.darkThemeColor,
  });

  final String? label;
  final Icon? icon;
  final Color lightThemeColor;
  final Color darkThemeColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Row(
      children: [
        Badge(
          badgeAnimation: const BadgeAnimation.fade(toAnimate: false),
          badgeStyle: BadgeStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            shape: BadgeShape.square,
            badgeColor: useDarkTheme ? darkThemeColor : lightThemeColor,
            borderRadius: BorderRadius.circular(8),
            elevation: 0,
          ),
          badgeContent: (label != null)
              ? Text(
                  label!,
                  style: theme.textTheme.labelMedium?.copyWith(fontSize: fontSize ?? 12),
                )
              : (icon != null)
                  ? icon
                  : null,
        ),
        const SizedBox(width: 8.0),
      ],
    );
  }
}
