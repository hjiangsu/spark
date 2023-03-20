import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayer extends StatefulWidget {
  final Function(VideoPlayerController)? onVideoInitialized;

  const VideoPlayer({
    required this.videoUrl,
    required this.urlKey,
    this.height,
    this.width,
    this.authorization,
    this.showControls = false,
    this.onVideoInitialized,
    this.ratio,
    this.nsfw = false,
  }) : super(key: urlKey);

  final Key urlKey;

  final String videoUrl;
  final double? height;
  final double? width;
  final double? ratio;
  final String? authorization;
  final bool showControls;
  final bool nsfw;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  bool blur = false;
  double endBlur = 15;
  double startBlur = 0;

  @override
  void initState() {
    super.initState();
    setState(() => blur = widget.nsfw);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllers(widget.videoUrl);
    });
  }

  Future<void> _initControllers(String url) async {
    FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(url);

    if (fileInfo != null) {
      _controller = VideoPlayerController.file(
        fileInfo.file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      _controller = VideoPlayerController.network(
        url,
        httpHeaders: widget.authorization != null
            ? {
                'content-Type': 'application/json',
                'accept': 'application/json',
                'authorization': 'Bearer ${widget.authorization}',
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
              }
            : {},
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    await _controller?.initialize();
    double aspectRatio = _controller!.value.aspectRatio;

    _chewie = ChewieController(
      looping: true,
      showControlsOnInitialize: false,
      showControls: widget.showControls,
      videoPlayerController: _controller!,
      aspectRatio: aspectRatio,
      allowPlaybackSpeedChanging: false,
      autoInitialize: true,
      placeholder: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      ),
      // overlay: GestureDetector(onTap: () => _controller.value.isPlaying ? _controller.pause() : _controller.play()
      //     // child: IconButton(onPressed: () => _controller.play(), icon: Icon(Icons.play_arrow)),
      //     ),
    );
    _chewie?.setVolume(0.0);
    if (widget.onVideoInitialized != null) widget.onVideoInitialized!(_controller!);
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewie?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewie != null) {
      return GestureDetector(
        onTap: () {
          if (widget.nsfw && blur) {
            setState(() => blur = false);
          }
        },
        child: Stack(
          children: [
            Chewie(key: widget.key, controller: _chewie!),
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
      );
    } else {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey.shade900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }
}
