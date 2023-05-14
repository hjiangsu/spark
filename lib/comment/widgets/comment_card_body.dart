import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentCardBody extends StatefulWidget {
  String body;

  CommentCardBody({super.key, required this.body});

  @override
  State<CommentCardBody> createState() => _CommentCardBodyState();
}

class _CommentCardBodyState extends State<CommentCardBody> {
  RegExp linkRegex = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

  List<String?> links = [];

  @override
  void initState() {
    Iterable<Match> matches = linkRegex.allMatches(HtmlUnescape().convert(widget.body));
    links = matches.map((match) => match.group(0)).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> content = [
      MarkdownBody(
        data: HtmlUnescape().convert(widget.body),
        onTapLink: (text, url, title) {
          launchUrl(Uri.parse(url!));
        },
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyMedium,
            blockquoteDecoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(left: BorderSide(color: Colors.grey, width: 4)),
            )),
      ),
      links.isNotEmpty ? const SizedBox(height: 8.0) : Container(),
    ];

    content.addAll(
      links.map((link) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(40),
          ),
          onPressed: () => launchUrl(Uri.parse(link)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  link!,
                  maxLines: 1,
                  minFontSize: 13,
                  maxFontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded)
            ],
          ),
        );
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
