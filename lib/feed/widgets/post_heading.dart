import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/feed/bloc/feed_bloc.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/feed/feed.dart';

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
    final fontSizeScale = context.read<ThemeBloc>().state.fontSizeScale;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
                GestureDetector(
                  // onTap: () => context.read<FeedBloc>().add(FeedRefreshed(subreddit: post.subreddit)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FeedPage(subreddit: post.subreddit))),
                  child: Text(
                    post.subreddit,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: useDarkTheme ? Colors.grey.shade400 : Colors.grey.shade900,
                    ),
                  ),
                ),
                Text(
                  ' · ${formatTimeToString(epochTime: post.createdAt.toInt())} · ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: useDarkTheme ? Colors.grey.shade400 : Colors.grey.shade900,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(username: widget.post.author!)));
                    context.read<FeedBloc>().add(FeedRefreshed(subreddit: 'u_${post.author}'));
                  },
                  child: Text(
                    post.author,
                    style: theme.textTheme.bodyMedium?.copyWith(
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
