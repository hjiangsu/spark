import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/feed/bloc/feed_bloc.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/utils/datetime.dart';

class PostHeading extends StatelessWidget {
  const PostHeading({
    super.key,
    required this.post,
  });

  final RedditSubmission post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            HtmlUnescape().convert(post.title),
            style: theme.textTheme.titleSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.read<FeedBloc>().add(FeedRefreshed(subreddit: post.subreddit)),
                  child: Text(
                    post.subreddit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: useDarkTheme ? Colors.grey.shade400 : Colors.grey.shade900,
                    ),
                  ),
                ),
                Text(
                  ' · ${formatTimeToString(epochTime: post.createdAt.toInt())} · ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: useDarkTheme ? Colors.grey.shade400 : Colors.grey.shade900,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(username: widget.post.author!)));
                  },
                  child: Text(
                    post.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: useDarkTheme ? Colors.grey.shade400 : Colors.grey.shade900,
                    ),
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