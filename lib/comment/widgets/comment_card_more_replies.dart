import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/comment/bloc/comment_bloc.dart';

class CommentCardMoreReplies extends StatefulWidget {
  int level;

  String submissionId;
  String? commentId;

  CommentCardMoreReplies({super.key, this.level = 0, required this.submissionId, this.commentId});

  @override
  State<CommentCardMoreReplies> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCardMoreReplies> {
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  bool isLoading = false;

  @override
  void initState() {
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<CommentBloc>().add(
                          CommentFetched(
                            submissionId: widget.submissionId,
                            commentId: widget.commentId,
                          ),
                        );
                    setState(() {
                      isLoading = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'View more replies',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                              ),
                              isLoading
                                  ? const SizedBox(
                                      height: 12.0,
                                      width: 12.0,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
