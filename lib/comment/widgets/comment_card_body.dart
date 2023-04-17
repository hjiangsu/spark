import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:html_unescape/html_unescape.dart';

class CommentCardBody extends StatelessWidget {
  String body;

  CommentCardBody({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: MarkdownBody(
        data: HtmlUnescape().convert(body),
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyMedium,
            blockquoteDecoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(left: BorderSide(color: Colors.grey, width: 4)),
            )),
      ),
    );
  }
}
