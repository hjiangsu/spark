import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final Function(VideoPlayerController)? onVideoInitialized;

  const VideoPlayer({
    required this.url,
    required this.playerKey,
    this.height,
    this.width,
    this.showControls = false,
    this.onVideoInitialized,
    this.authorizationToken,
  }) : super(key: playerKey);

  final Key playerKey;

  final String url;
  final double? height;
  final double? width;
  final bool showControls;

  final String? authorizationToken;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initControllers(widget.url));
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
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        httpHeaders: widget.authorizationToken != null
            ? {
                'content-Type': 'application/json',
                'accept': 'application/json',
                'authorization': 'Bearer ${widget.authorizationToken}',
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
              }
            : {},
      );
    }

    await _controller?.initialize();
    double aspectRatio = _controller!.value.aspectRatio;

    final prefs = await SharedPreferences.getInstance();
    bool? videoAutoplay = prefs.getBool('videoAutoplay');

    _chewie = ChewieController(
      looping: true,
      showControlsOnInitialize: false,
      showControls: widget.showControls,
      videoPlayerController: _controller!,
      aspectRatio: aspectRatio,
      allowPlaybackSpeedChanging: false,
      autoInitialize: true,
      autoPlay: videoAutoplay ?? true,
      placeholder: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    _chewie?.setVolume(0.0);
    widget.onVideoInitialized!(_controller!);
    // if (widget.onVideoInitialized != null && _controller != null) {
    //   widget.onVideoInitialized!(_controller!);
    // }

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
          if (_controller != null && _controller!.value.isPlaying) {
            _controller?.pause();
          } else {
            _controller?.play();
          }
        },
        child: Stack(
          children: [
            Chewie(key: widget.key, controller: _chewie!),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: blur ? startBlur : endBlur, end: blur ? endBlur : startBlur),
              duration: const Duration(milliseconds: 0),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }
}
