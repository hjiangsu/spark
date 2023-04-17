import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:spark/core/models/media/media.dart';
import 'package:spark/widgets/image_preview/image_preview.dart';
import 'package:spark/widgets/link_preview_card/link_preview_card.dart';
import 'package:spark/core/models/reddit_submission/reddit_submission.dart';
import 'package:spark/widgets/video_player/video_player.dart' as CustomVideoPlayer;

class MediaView extends StatefulWidget {
  MediaView({
    super.key,
    required this.post,
    this.showVideoControls = false,
  });

  RedditSubmission post;
  bool showVideoControls;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  VideoPlayerController? videoController;

  @override
  Widget build(BuildContext context) {
    if (widget.post.video != null) {
      String url = widget.post.video!.url;

      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.post.video?.height ?? 300, maxWidth: widget.post.video?.width ?? 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: VisibilityDetector(
              key: Key(url),
              onVisibilityChanged: (visibilityInfo) {
                double visiblePercentage = visibilityInfo.visibleFraction * 100;

                if (visiblePercentage > 90) {
                  videoController?.play();
                } else {
                  videoController?.pause();
                }
              },
              child: CustomVideoPlayer.VideoPlayer(
                url: url,
                playerKey: Key(url),
                showControls: widget.showVideoControls,
                width: widget.post.video?.width?.toDouble(),
                height: widget.post.video?.height?.toDouble(),
                onVideoInitialized: (VideoPlayerController _videoController) => setState(() {
                  videoController = _videoController;
                }),
              ),
            ),
          ),
        ),
      );
    }

    // Display a carousel of images for galleries
    if (widget.post.gallery != null) {
      List<Media> media = widget.post.gallery!;

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

    // Display a preview of the image if available.
    if (widget.post.image != null) {
      return ImagePreview(
        url: widget.post.image!.url,
        height: widget.post.image!.height!,
        width: widget.post.image!.width!,
        nsfw: false,
      );
    }

    // For any links that are considered to be external, generate a card for them
    if (widget.post.externalLink != null) {
      return LinkPreviewCard(originURL: widget.post.externalLink!.url);
    }

    return Container();
  }
}
