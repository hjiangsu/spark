import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:spark/feed/widgets/feed_card_heading.dart';
import 'package:spark/models/media/media.dart';
import 'package:spark/models/reddit_submission/reddit_submission.dart';
import 'package:spark/theme/bloc/theme_bloc.dart';
import 'package:spark/widgets/image_preview/image_preview.dart';
import 'package:spark/widgets/link_preview_card/link_preview_card.dart';
import 'package:spark/widgets/submission_badge/submission_badge.dart';

class FeedCard extends StatefulWidget {
  const FeedCard({
    super.key,
    required this.post,
  });

  final RedditSubmission post;

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    print('video: ${widget.post.video}');
    print('image: ${widget.post.image}');
    print('gallery: ${widget.post.gallery}');
    print('external: ${widget.post.externalLink}');
    print('');

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
                  mediaWidget(),
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
                                HtmlUnescape().convert(widget.post.title),
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
                                  widget.post.nsfw
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

  Widget getImageCarouselWidget(List<Media> media) {
    return CarouselSlider(
      options: CarouselOptions(
        enableInfiniteScroll: false,
        aspectRatio: 1.0,
        enlargeCenterPage: true,
      ),
      items: media.map((media) {
        return Builder(
          builder: (BuildContext context) {
            return ImagePreview(
              url: media.url,
              width: media.width!,
              height: media.height!,
              nsfw: false,
            );
          },
        );
      }).toList(),
    );
  }

  Widget mediaWidget() {
    // if (widget.post.video != null) {
    //   return getVideoWidget(widget.post.videoURL);
    // }

    if (widget.post.gallery != null) {
      return getImageCarouselWidget(widget.post.gallery!);
    }

    if (widget.post.image != null) {
      return ImagePreview(
        url: widget.post.image!.url,
        height: widget.post.image!.height!,
        width: widget.post.image!.width!,
        nsfw: false,
      );
    }

    if (widget.post.externalLink != null) {
      return LinkPreviewCard(originURL: widget.post.externalLink!.url);
    }

    return Container();
  }
}
