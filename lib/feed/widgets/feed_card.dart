import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/core/utils/numbers.dart';
import 'package:spark/feed/bloc/feed_bloc.dart';

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
  List<Widget> buttonList = [];

  List<Text> labelList = const <Text>[Text('Upvote'), Text('Downvote'), Text('Save')];

  // Preferences
  bool showPostTitleOnTop = false;

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showPostTitleOnTop = prefs.getBool('showPostTitleOnTop') ?? false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());

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
            List<Widget> buttonList = [
              IconButton(
                onPressed: () {
                  context.read<FeedBloc>().add(FeedPostVoted(postId: widget.post.id, vote: true));
                  context.pop();
                },
                icon: const Icon(Icons.north),
                color: widget.post.upvoted ? Colors.orange : null,
              ),
              IconButton(
                onPressed: () {
                  context.read<FeedBloc>().add(FeedPostVoted(postId: widget.post.id, vote: false));
                  context.pop();
                },
                icon: const Icon(Icons.south),
                color: widget.post.downvoted ? Colors.blue : null,
              ),
              IconButton(
                onPressed: () {
                  context.read<FeedBloc>().add(FeedPostSaved(postId: widget.post.id));
                  context.pop();
                },
                icon: Icon(widget.post.saved ? Icons.bookmark : Icons.bookmark_border_rounded),
              ),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ];
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showPostTitleOnTop == true)
                  Text(
                    HtmlUnescape().convert(widget.post.title),
                    style: theme.textTheme.titleMedium,
                    softWrap: true,
                  ),
                MediaView(post: widget.post),
                if (showPostTitleOnTop == false)
                  Text(
                    HtmlUnescape().convert(widget.post.title),
                    style: theme.textTheme.titleMedium,
                    softWrap: true,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'r/${widget.post.subreddit}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconText(
                                  text: formatNumberToK(widget.post.upvoteCount),
                                  icon: Icon(
                                    Icons.arrow_upward,
                                    size: 18.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  textColor: widget.post.upvoted
                                      ? Colors.orange
                                      : widget.post.downvoted
                                          ? Colors.blue
                                          : null,
                                  padding: 2.0,
                                ),
                                const SizedBox(width: 12.0),
                                IconText(
                                  icon: Icon(
                                    Icons.chat,
                                    size: 17.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  text: formatNumberToK(widget.post.commentCount),
                                  padding: 5.0,
                                ),
                                const SizedBox(width: 10.0),
                                IconText(
                                  icon: Icon(
                                    Icons.history_rounded,
                                    size: 19.0,
                                    color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                                  ),
                                  text: formatTimeToString(epochTime: widget.post.createdAt.toInt()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<FeedBloc>().add(FeedPostVoted(postId: widget.post.id, vote: true));
                            },
                            icon: Icon(
                              Icons.arrow_upward,
                              color: widget.post.upvoted ? Colors.orange : null,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<FeedBloc>().add(FeedPostVoted(postId: widget.post.id, vote: false));
                            },
                            icon: Icon(
                              Icons.arrow_downward,
                              color: widget.post.downvoted ? Colors.blue : null,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<FeedBloc>().add(FeedPostSaved(postId: widget.post.id));
                            },
                            icon: Icon(widget.post.saved ? Icons.bookmark : Icons.bookmark_border_rounded),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
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
