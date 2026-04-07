import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Shared Chewie setup for Mux HLS (detail / full-screen player).
class MuxChewieFactory {
  MuxChewieFactory._();

  /// Full-screen style player (detail page): controls, scrubbing, autoplay.
  static ChewieController fullPlayer({
    required VideoPlayerController videoPlayerController,
    required bool isLive,
    Widget? overlay,
  }) {
    return ChewieController(
      videoPlayerController: videoPlayerController,
      isLive: isLive,
      draggableProgressBar: !isLive,
      allowPlaybackSpeedChanging: !isLive,
      autoPlay: true,
      looping: false,
      overlay: overlay,
    );
  }
}
