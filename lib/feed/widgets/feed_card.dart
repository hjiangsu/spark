import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/post/views/post_page.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/utils/numbers.dart';
import 'package:spark/feed/widgets/post_heading.dart';
import 'package:spark/widgets/badge_list/badge_list.dart';

import 'package:spark/widgets/icon_text/icon_text.dart';
import 'package:spark/widgets/media_view/media_view.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.post,
    this.showDivider = true,
  });

  final RedditSubmission post;
  final bool showDivider;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Column(
      children: [
        widget.showDivider ? Divider(height: 1.0, color: useDarkTheme ? Colors.grey.shade800 : Colors.grey.shade100) : Container(),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MediaView(post: widget.post),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PostHeading(post: widget.post),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              BadgeList(post: widget.post),
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    IconText(
                                      text: formatNumberToK(widget.post.upvoteCount),
                                      leadingIcon: Icons.arrow_upward,
                                      leadingIconColor: widget.post.upvoted == true ? Colors.amber.shade700 : null,
                                      suffixIcon: Icons.arrow_downward,
                                      suffixIconColor: widget.post.downvoted == true ? Colors.blue.shade600 : null,
                                      onTap: () {
                                        // placeholder for logic to upvote, downvote, or no vote submissions
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder for logic to upvote')));
                                      },
                                      onDoubleTap: () {
                                        // placeholder for logic to upvote, downvote, or no vote submissions
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder for logic to downvote')));
                                      },
                                    ),
                                    const SizedBox(width: 12.0),
                                    IconText(
                                      leadingIcon: Icons.chat,
                                      text: formatNumberToK(widget.post.commentCount),
                                    ),
                                  ],
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
            ),
          ),
          onTap: () => {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(postId: widget.post.id))),
          },
        ),
      ],
    );
  }
}
