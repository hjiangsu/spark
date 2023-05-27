import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreview extends StatefulWidget {
  final String url;
  final bool nsfw;
  final double height;
  final double width;
  final bool isGallery;

  const ImagePreview({super.key, required this.url, required this.height, required this.width, this.nsfw = false, this.isGallery = false});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  PhotoViewController photoViewController = PhotoViewController();

  bool blur = false;
  double endBlur = 15;
  double startBlur = 0;

  @override
  void initState() {
    super.initState();
    setState(() => blur = widget.nsfw);
  }

  void onImageTap() {
    final theme = Theme.of(context);

    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                PhotoView(
                  controller: photoViewController,
                  imageProvider: CachedNetworkImageProvider(widget.url),
                  backgroundDecoration: BoxDecoration(color: theme.cardColor),
                ),
                IconButton(
                  color: theme.textTheme.titleLarge!.color,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Image border
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.url,
                  height: widget.isGallery ? null : widget.height,
                  width: widget.isGallery ? null : widget.width,
                  memCacheHeight: widget.height.toInt(),
                  memCacheWidth: widget.width.toInt(),
                  fit: BoxFit.fitWidth,
                  progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(value: downloadProgress.progress),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: blur ? startBlur : endBlur, end: blur ? endBlur : startBlur),
                  duration: Duration(milliseconds: widget.nsfw ? 250 : 0),
                  builder: (_, value, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                      child: child,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            if (widget.nsfw && blur) {
              setState(() => blur = false);
            } else {
              onImageTap();
            }
          },
        ),
      ),
    );
  }
}
