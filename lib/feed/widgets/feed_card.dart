import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/feed/widgets/feed_card_heading.dart';
import 'package:spark/theme/bloc/theme_bloc.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.post,
  });

  final dynamic post;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    return Column(
      children: [
        Divider(height: 1.0, color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade100),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // mediaWidget(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                HtmlUnescape().convert(widget.post['title']),
                                style: theme.textTheme.titleSmall,
                              ),
                              FeedCardHeading(post: widget.post),
                            ],
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  // pinnedBadge(),
                                  // contentBadge(),
                                  widget.post['over_18']
                                      ? Badge(
                                          badgeAnimation: const BadgeAnimation.fade(toAnimate: false),
                                          badgeStyle: BadgeStyle(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            shape: BadgeShape.square,
                                            badgeColor: const Color.fromARGB(255, 160, 53, 45),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          badgeContent: Text(
                                            'NSFW',
                                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                                          ),
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
                              ),
                              //       IntrinsicHeight(
                              //         child: Row(
                              //           children: [
                              //             IconText(
                              //               text: formatNumberToK(widget.post.upvotes),
                              //               leadingIcon: Icons.arrow_upward,
                              //               leadingIconColor: widget.post.upvoted == true ? Colors.amber.shade700 : null,
                              //               suffixIcon: Icons.arrow_downward,
                              //               suffixIconColor: widget.post.upvoted == false ? Colors.blue.shade600 : null,
                              //               onTap: () {
                              //                 // placeholder for logic to upvote, downvote, or no vote submissions
                              //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Placeholder for logic to upvote')));
                              //               },
                              //               onDoubleTap: () {
                              //                 // placeholder for logic to upvote, downvote, or no vote submissions
                              //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Placeholder for logic to downvote')));
                              //               },
                              //             ),
                              //             const SizedBox(width: 12.0),
                              //             IconText(
                              //               leadingIcon: Icons.chat,
                              //               text: formatNumberToK(widget.post.comments),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
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
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(postId: widget.post.id))),
          },
        ),
      ],
    );
  }
}
