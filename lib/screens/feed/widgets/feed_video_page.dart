import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/feed_video.dart';
import 'package:ghost_money_world/screens/feed/feed_controller.dart';
import 'package:ghost_money_world/screens/feed/widgets/feed_comments_sheet.dart';
import 'package:video_player/video_player.dart';

class FeedVideoPage extends StatefulWidget {
  final FeedVideo video;
  final bool isActive;

  const FeedVideoPage({super.key, required this.video, required this.isActive});

  @override
  State<FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<FeedVideoPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _loadFailed = false;
  bool _muted = false;

  bool get _shouldPlay {
    if (!widget.isActive) return false;
    if (!Get.isRegistered<FeedController>(tag: 'feed')) return widget.isActive;
    return Get.find<FeedController>(tag: 'feed').tabVisible;
  }

  @override
  void initState() {
    super.initState();
    if (_shouldPlay) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(covariant FeedVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldPlay = _shouldPlay;
    final oldShouldPlay =
        oldWidget.isActive &&
        (Get.isRegistered<FeedController>(tag: 'feed')
            ? Get.find<FeedController>(tag: 'feed').tabVisible
            : oldWidget.isActive);

    if (shouldPlay && !oldShouldPlay) {
      _initPlayer();
    } else if (!shouldPlay && oldShouldPlay) {
      _pauseAndRelease();
    } else if (shouldPlay &&
        _controller != null &&
        !_controller!.value.isPlaying) {
      _controller?.play();
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    if (_controller != null) return;

    final url = widget.video.streamUrl;
    if (url.isEmpty) {
      setState(() => _loadFailed = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      await controller.play();
      setState(() {
        _initialized = true;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadFailed = true);
      }
      _disposePlayer();
    }
  }

  void _disposePlayer() {
    _controller?.dispose();
    _controller = null;
    _initialized = false;
  }

  void _pauseAndRelease() {
    _controller?.pause();
    _disposePlayer();
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null || !_initialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  Future<void> _toggleMute() async {
    final c = _controller;
    if (c == null) return;
    _muted = !_muted;
    await c.setVolume(_muted ? 0 : 1);
    setState(() {});
  }

  void _openComments() {
    Get.bottomSheet(
      FeedCommentsSheet(video: widget.video),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      tag: 'feed',
      builder: (controller) {
        if (widget.isActive) {
          if (controller.tabVisible && _controller == null && !_loadFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _shouldPlay) _initPlayer();
            });
          } else if (!controller.tabVisible && _controller != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _pauseAndRelease();
            });
          }
        }

        final interactions = controller.interactionsFor(widget.video.id);

        return GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMedia(),
              if (_initialized &&
                  _controller != null &&
                  !_controller!.value.isPlaying)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 72,
                  ),
                ),
              Positioned(
                right: 12.w,
                bottom: 110.h,
                child: _FeedActionColumn(
                  liked: interactions.likedByMe,
                  likeLabel: controller.formatCount(interactions.likeCount),
                  commentLabel: controller.formatCount(
                    interactions.commentCount,
                  ),
                  muted: _muted,
                  onLike: () => controller.toggleLike(widget.video.id),
                  onComment: _openComments,
                  onShare: () => controller.shareVideo(widget.video),
                  onMute: _toggleMute,
                ),
              ),
              Positioned(
                left: 16.w,
                right: 80.w,
                bottom: 24.h,
                child: _FeedInfoOverlay(video: widget.video),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedia() {
    if (_loadFailed) {
      return _thumbnailFallback();
    }

    if (_initialized && _controller != null) {
      final c = _controller!;
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _thumbnailFallback(),
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ],
    );
  }

  Widget _thumbnailFallback() {
    final thumb = widget.video.thumbnail;
    if (thumb.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }
    return CachedNetworkImage(
      imageUrl: thumb,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _FeedInfoOverlay extends StatelessWidget {
  final FeedVideo video;

  const _FeedInfoOverlay({required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (video.title.isNotEmpty)
          customText(
            text: video.title,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            maxLines: 2,
          ),
        if (video.description.isNotEmpty) ...[
          SizedBox(height: 6.h),
          customText(
            text: video.description,
            color: Colors.white70,
            fontSize: 13.sp,
            maxLines: 3,
          ),
        ],
      ],
    );
  }
}

class _FeedActionColumn extends StatelessWidget {
  final bool liked;
  final String likeLabel;
  final String commentLabel;
  final bool muted;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMute;

  const _FeedActionColumn({
    required this.liked,
    required this.likeLabel,
    required this.commentLabel,
    required this.muted,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          label: likeLabel,
          iconColor: liked ? AppColors.redFF2B3A : Colors.white,
          onTap: onLike,
        ),
        SizedBox(height: 18.h),
        _ActionButton(
          icon: CupertinoIcons.chat_bubble_text,
          label: commentLabel,
          onTap: onComment,
        ),
        SizedBox(height: 18.h),
        _ActionButton(
          icon: Icons.share_outlined,
          label: '',
          showLabel: false,
          onTap: onShare,
        ),
        SizedBox(height: 18.h),
        _ActionButton(
          icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          label: muted ? 'Muted' : 'Sound',
          onTap: onMute,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool showLabel;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26.sp),
          ),
          if (showLabel) ...[
            SizedBox(height: 4.h),
            customText(
              text: label,
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ],
      ),
    );
  }
}
