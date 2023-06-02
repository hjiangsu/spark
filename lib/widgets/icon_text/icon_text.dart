import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.textColor,
  });

  final Icon icon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        icon,
        const SizedBox(width: 4.0),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
