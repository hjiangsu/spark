import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/core/models/reddit_comment/reddit_comment.dart';

class CommentCard extends StatefulWidget {
  RedditComment comment;
  int level;
  bool collapsed;

  CommentCard({super.key, required this.comment, this.level = 0, this.collapsed = false});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  List<Color> colors = [Colors.red.shade300, Colors.orange.shade300, Colors.yellow.shade300, Colors.green.shade300, Colors.blue.shade300, Colors.indigo.shade300];

  bool isHidden = true;

  @override
  void initState() {
    isHidden = widget.collapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4.0,
            color: colors[(widget.level % 6).toInt()],
          ),
        ),
      ),
      margin: widget.level != 0 ? const EdgeInsets.only(left: 1.0) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isHidden = !isHidden),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: isHidden ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            HtmlUnescape().convert(widget.comment.author),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                isHidden ? Container() : Text(HtmlUnescape().convert(widget.comment.body)),
              ],
            ),
          ),
          isHidden
              ? Container()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CommentCard(
                      comment: widget.comment.replies[index],
                      level: widget.level + 1,
                      collapsed: widget.level > 3,
                    );
                  },
                  itemCount: widget.comment.replies?.length,
                ),
        ],
      ),
    );
  }
}
