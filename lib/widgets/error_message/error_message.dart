import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.message,
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSizeScale = context.read<ThemeBloc>().state.fontSizeScale;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.warning_rounded,
            size: 100,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
