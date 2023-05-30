import 'package:flutter/material.dart';

// Packages
import 'package:html_unescape/html_unescape.dart';

// Spark
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';

class PostHeading extends StatelessWidget {
  const PostHeading({super.key, required this.post});

  final RedditSubmission post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            HtmlUnescape().convert(post.title),
            style: theme.textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  post.subreddit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
                Text(
                  ' · ${formatTimeToString(epochTime: post.createdAt.toInt())} · ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
                Text(
                  post.author,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
