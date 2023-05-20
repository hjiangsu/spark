import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
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
  List<Widget> buttonList = <Widget>[
    IconButton(onPressed: () {}, icon: const Icon(Icons.expand_less_rounded, size: 30.0)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.expand_more_rounded, size: 30.0)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark)),
    IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
  ];

  List<Text> labelList = const <Text>[Text('Upvote'), Text('Downvote'), Text('Save'), Text('Share')];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (widget.showDivider)
          Divider(
            height: 1.0,
            thickness: 2.0,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.20),
          ),
        InkWell(
          onLongPress: () {
            showModalBottomSheet<void>(
              showDragHandle: true,
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: buttonList.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              buttonList[index],
                              labelList[index],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 16.0,
                      endIndent: 16.0,
                    ),
                    SingleChildScrollView(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ListTile(
                            title: Text(
                              'Go to Subreddit',
                              style: theme.textTheme.bodyMedium,
                            ),
                            leading: const Icon(Icons.reply_rounded),
                            onTap: () {
                              context.pop();
                              context.push('/feed/subreddit/${widget.post.subreddit}');
                            },
                          ),
                          ListTile(
                            title: Text(
                              'Go to Redditor',
                              style: theme.textTheme.bodyMedium,
                            ),
                            leading: const Icon(Icons.person_search_rounded),
                            onTap: () {
                              context.pop();
                              context.push('/feed/redditor/${widget.post.author}');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                );
              },
            );
          },
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
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Placeholder for logic to upvote')));
                                      },
                                      onDoubleTap: () {
                                        // placeholder for logic to upvote, downvote, or no vote submissions
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Placeholder for logic to downvote')));
                                      },
                                    ),
                                    const SizedBox(width: 12.0),
                                    IconText(
                                      leadingIcon: Icons.chat,
                                      text: formatNumberToK(widget.post.commentCount),
                                    ),
                                    const SizedBox(width: 4.0),
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
          onTap: () {
            GoRouter.of(context).push('${GoRouter.of(context).location}/post/${widget.post.id}');
          },
        ),
      ],
    );
  }
}
