import 'package:flutter/material.dart';

import 'package:html_unescape/html_unescape.dart';

import 'package:spark/comment/widgets/comment_card_body.dart';
import 'package:spark/comment/widgets/comment_card_more_replies.dart';

import 'package:spark/core/models/reddit_comment/reddit_comment.dart';
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/core/utils/numbers.dart';

class CommentCard extends StatefulWidget {
  /// Creates a comment card
  CommentCard({
    super.key,
    required this.comment,
    this.level = 0,
    this.collapsed = false,
  });

  /// Comment containing relevant information
  RedditComment comment;

  /// The level of the comment within the comment tree - a higher level indicates a greater indentation
  int level;

  /// Whether the comment is collapsed or expanded
  bool collapsed;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  bool isHidden = true;
  GlobalKey childKey = GlobalKey();

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
        border: widget.level > 0
            ? Border(
                left: BorderSide(
                  width: 4.0,
                  color: colors[((widget.level - 1) % 6).toInt()],
                ),
              )
            : const Border(),
      ),
      margin: const EdgeInsets.only(left: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => isHidden = !isHidden),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              HtmlUnescape().convert(widget.comment.author),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.north, size: 12.0),
                            const SizedBox(width: 2.0),
                            Text(
                              HtmlUnescape().convert(formatNumberToK(widget.comment.upvotes)),
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatTimeToString(epochTime: widget.comment.createdAt.toInt()),
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground),
                      )
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: isHidden ? 0.0 : 1.0,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 200),
                  child: isHidden ? Container() : CommentCardBody(body: widget.comment.body),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            key: childKey,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            child: AnimatedOpacity(
              opacity: isHidden ? 0.0 : 1.0,
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => CommentCard(
                  comment: widget.comment.replies[index],
                  level: widget.level + 1,
                  collapsed: widget.level > 2,
                ),
                itemCount: isHidden ? 0 : widget.comment.replies?.length,
              ),
            ),
          ),
          (widget.comment.children.length > 0 && isHidden == false)
              ? CommentCardMoreReplies(level: widget.level + 1, submissionId: widget.comment.submissionId, commentId: widget.comment.id)
              : Container(),
        ],
      ),
    );
  }
}
