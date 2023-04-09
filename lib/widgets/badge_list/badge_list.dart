import 'package:flutter/material.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/widgets/submission_badge/submission_badge.dart';

class BadgeList extends StatelessWidget {
  const BadgeList({super.key, required this.post});

  final RedditSubmission post;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        post.pinned
            ? SubmissionBadge(
                icon: Icon(
                  Icons.campaign_rounded,
                  size: 22.0,
                  color: Colors.green.shade800,
                ),
                lightThemeColor: Colors.transparent,
                darkThemeColor: Colors.transparent,
              )
            : Container(),
        post.video != null
            ? const SubmissionBadge(
                label: 'VIDEO',
                lightThemeColor: Color.fromARGB(97, 82, 45, 168),
                darkThemeColor: Color.fromARGB(97, 82, 45, 168),
              )
            : Container(),
        (post.image != null || post.gallery != null)
            ? const SubmissionBadge(
                label: 'IMAGE',
                lightThemeColor: Color.fromARGB(99, 56, 142, 60),
                darkThemeColor: Color.fromARGB(99, 56, 142, 60),
              )
            : Container(),
        post.text != null
            ? const SubmissionBadge(
                label: 'TEXT',
                lightThemeColor: Color.fromARGB(95, 45, 123, 168),
                darkThemeColor: Color.fromARGB(95, 45, 123, 168),
              )
            : Container(),
        post.nsfw
            ? const SubmissionBadge(
                label: 'NSFW',
                lightThemeColor: Color.fromARGB(255, 248, 194, 190),
                darkThemeColor: Color.fromARGB(255, 160, 53, 45),
              )
            : Container(),
        // widget.post['saved']
        //     ? Icon(
        //         Icons.bookmark,
        //         color: Colors.grey.shade400,
        //         size: 16.0,
        //       )
        //     : Container(),
      ],
    );
  }
}
