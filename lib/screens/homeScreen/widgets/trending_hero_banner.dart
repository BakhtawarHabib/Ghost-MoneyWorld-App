import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/player/mux_chewie_factory.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/splash/videoDetailScreen.dart';
import 'package:video_player/video_player.dart';

/// Same player as [VideoDetailPage]: `ClipRRect` + `AspectRatio` 16:9 + [MuxChewieFactory.fullPlayer].
/// Yellow **Watch Now** is [Positioned] on the video (bottom-left) only while playback is stopped.
class TrendingHeroBanner extends StatefulWidget {
  final VideoModel video;

  const TrendingHeroBanner({super.key, required this.video});

  @override
  State<TrendingHeroBanner> createState() => _TrendingHeroBannerState();
}

class _TrendingHeroBannerState extends State<TrendingHeroBanner> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _initialized = false;
  bool _loadFailed = false;
  bool _lastIsPlaying = false;

  String get _thumbUrl {
    final t = widget.video.thumbnail.trim();
    if (t.isNotEmpty) return t;
    return widget.video.resolvedThumbnail;
  }

  String get _playUrl => widget.video.resolvedVideoUrl;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void didUpdateWidget(covariant TrendingHeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
      _disposePlayer();
      setState(() {
        _initialized = false;
        _loadFailed = false;
        _lastIsPlaying = false;
      });
      _setupPlayer();
    }
  }

  void _onVideoTick() {
    final c = _videoController;
    if (c == null || !mounted) return;
    if (c.value.hasError) {
      c.removeListener(_onVideoTick);
      setState(() => _loadFailed = true);
      _disposePlayer();
      return;
    }
    final playing = c.value.isPlaying;
    if (playing != _lastIsPlaying) {
      _lastIsPlaying = playing;
      setState(() {});
    }
  }

  Future<void> _setupPlayer() async {
    final url = _playUrl;
    if (url.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loadFailed = true);
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    _videoController = controller;
    controller.addListener(_onVideoTick);

    try {
      await controller.initialize();
      if (!mounted) return;
      if (controller.value.hasError) {
        setState(() => _loadFailed = true);
        _disposePlayer();
        return;
      }

      _chewieController = MuxChewieFactory.fullPlayer(
        videoPlayerController: controller,
        isLive: false,
        overlay: null,
      );

      if (!mounted) return;
      setState(() {
        _initialized = true;
        _lastIsPlaying = controller.value.isPlaying;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
      _disposePlayer();
    }
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _openDetail() {
    final v = widget.video;
    VideoLoginPrompt.guardVideoAccess(
      onAuthorized: () {
        _videoController?.pause();
        Get.to(
          () => VideoDetailPage(
            id: v.id,
            title: v.title,
            description: v.description,
            categoryId: v.category,
            videoUrl: v.resolvedVideoUrl,
            thumbnail: v.resolvedThumbnail,
          ),
        );
      },
    );
  }

  bool get _playerReady =>
      _chewieController != null &&
      _initialized &&
      (_videoController?.value.isInitialized ?? false) &&
      !_loadFailed;

  /// Yellow CTA only while nothing is playing (paused, ended, or not started yet).
  bool get _showWatchNowButton =>
      !(_videoController?.value.isPlaying ?? false);

  @override
  Widget build(BuildContext context) {
    final chewie = _chewieController;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: Colors.grey.shade900,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child:
                      _playerReady && chewie != null
                          ? Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: Theme.of(context).textTheme.apply(
                                bodyColor: Colors.white,
                                displayColor: Colors.white,
                              ),
                            ),
                            child: Chewie(controller: chewie),
                          )
                          : _thumbUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: _thumbUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) =>
                                    ColoredBox(color: Colors.grey.shade900),
                            errorWidget:
                                (_, __, ___) =>
                                    ColoredBox(color: Colors.grey.shade800),
                          )
                          : const ColoredBox(color: Colors.black),
                ),
                if (!_initialized && !_loadFailed && _playUrl.isNotEmpty)
                  const IgnorePointer(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                if (_showWatchNowButton)
                  Positioned(
                    left: 12.w,
                    bottom: 12.h,
                    child: Material(
                      color: const Color(0xfff4b304),
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _openDetail,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: customText(
                            text: "Watch Now",
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
