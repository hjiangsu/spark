import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.leadingIcon,
    this.leadingIconColor,
    required this.text,
    this.textColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.onTap,
    this.onDoubleTap,
  });

  final Function()? onTap;
  final Function()? onDoubleTap;

  final IconData leadingIcon;
  final Color? leadingIconColor;

  final IconData? suffixIcon;
  final Color? suffixIconColor;

  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          Icon(
            leadingIcon,
            size: leadingIconColor != null ? 20.0 : 16.0,
            weight: leadingIconColor != null ? 1000 : 350,
            color: leadingIconColor ?? theme.iconTheme.color,
          ),
          const SizedBox(width: 6.0),
          Text(text, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: textColor)),
          if (suffixIcon != null)
            Row(
              children: [
                const SizedBox(width: 6.0),
                Icon(
                  suffixIcon,
                  size: suffixIconColor != null ? 20.0 : 16.0,
                  weight: suffixIconColor != null ? 1000 : 350,
                  color: suffixIconColor ?? theme.iconTheme.color,
                ),
              ],
            ),
        ],
      ),
    );
    return IntrinsicHeight(
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap?.call(),
            onDoubleTap: () => onDoubleTap?.call(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Row(
                children: [
                  Icon(
                    leadingIcon,
                    size: leadingIconColor != null ? 20.0 : 16.0,
                    weight: leadingIconColor != null ? 1000 : 350,
                    color: leadingIconColor ?? theme.iconTheme.color,
                  ),
                  const SizedBox(width: 6.0),
                  Text(text, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                  if (suffixIcon != null)
                    Row(
                      children: [
                        const SizedBox(width: 6.0),
                        Icon(
                          suffixIcon,
                          size: suffixIconColor != null ? 20.0 : 16.0,
                          weight: suffixIconColor != null ? 1000 : 350,
                          color: suffixIconColor ?? theme.iconTheme.color,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
