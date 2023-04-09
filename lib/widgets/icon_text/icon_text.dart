import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({super.key, required this.leadingIcon, this.leadingIconColor, required this.text, this.suffixIcon, this.suffixIconColor, this.onTap, this.onDoubleTap});

  final Function()? onTap;
  final Function()? onDoubleTap;

  final IconData leadingIcon;
  final Color? leadingIconColor;

  final IconData? suffixIcon;
  final Color? suffixIconColor;

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap?.call(),
            onDoubleTap: () => onDoubleTap?.call(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(leadingIcon, size: leadingIconColor != null ? 20.0 : 16.0, color: leadingIconColor ?? theme.iconTheme.color, weight: leadingIconColor != null ? 1000 : 350),
                  const SizedBox(width: 4.0),
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  suffixIcon != null
                      ? Row(
                          children: [
                            const SizedBox(width: 4.0),
                            Icon(suffixIcon, size: suffixIconColor != null ? 20.0 : 16.0, color: suffixIconColor ?? theme.iconTheme.color),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}