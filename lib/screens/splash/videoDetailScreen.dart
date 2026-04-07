import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/live_stream_model.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/categories/categoriesController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/player/mux_chewie_factory.dart';
import 'package:ghost_money_world/widgets/live_broadcast_badge.dart';
import 'package:ghost_money_world/widgets/live_coming_soon_placeholder.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String videoUrl;
  final String thumbnail;

  /// Mux (or other) live HLS — uses Chewie live UI + LIVE badge.
  final bool isLiveStream;

  /// Firestore `liveStreams.status` (e.g. idle) — used to skip playback when off-air.
  final String liveStreamStatus;

  const VideoDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.videoUrl,
    required this.thumbnail,
    this.isLiveStream = false,
    this.liveStreamStatus = '',
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  String categoryName = "";
  List<VideoModel> moreVideos = [];

  bool _playerLoading = true;
  bool _liveComingSoon = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId.isNotEmpty) {
      _loadCategoryName();
      _loadMoreVideos();
    } else {
      categoryName = 'Live stream';
    }

    if (widget.isLiveStream &&
        LiveStreamModel.statusMeansNoBroadcast(widget.liveStreamStatus)) {
      _liveComingSoon = true;
      _playerLoading = false;
      return;
    }

    _initPlayer();
  }

  void _onVideoValueChanged() {
    final c = _videoController;
    if (c == null || !mounted) return;
    if (widget.isLiveStream && c.value.hasError) {
      c.removeListener(_onVideoValueChanged);
      _disposePlayer();
      setState(() {
        _liveComingSoon = true;
        _playerLoading = false;
      });
    }
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _initPlayer() async {
    if (widget.videoUrl.isEmpty) {
      if (mounted) setState(() => _playerLoading = false);
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
      _videoController = controller;
      controller.addListener(_onVideoValueChanged);

      await controller.initialize();

      if (!mounted) return;

      if (widget.isLiveStream && controller.value.hasError) {
        _disposePlayer();
        setState(() {
          _liveComingSoon = true;
          _playerLoading = false;
        });
        return;
      }

      _chewieController = MuxChewieFactory.fullPlayer(
        videoPlayerController: controller,
        isLive: widget.isLiveStream,
        overlay:
            widget.isLiveStream
                ? const Positioned(
                  top: 10,
                  left: 10,
                  child: LiveBroadcastBadge(),
                )
                : null,
      );

      setState(() => _playerLoading = false);
    } catch (_) {
      if (!mounted) return;
      _disposePlayer();
      if (widget.isLiveStream) {
        setState(() {
          _liveComingSoon = true;
          _playerLoading = false;
        });
      } else {
        setState(() => _playerLoading = false);
      }
    }
  }

  _loadCategoryName() async {
    final ctrl = Get.find<CategoriesController>();
    categoryName = await ctrl.getCategoryName(widget.categoryId);
    setState(() {});
  }

  _loadMoreVideos() async {
    final ctrl = Get.find<CategoriesController>();
    moreVideos = await ctrl.getVideosByCategory(widget.categoryId);

    moreVideos.removeWhere((v) => v.id == widget.id);
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoValueChanged);
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerReady =
        _chewieController != null &&
        (_videoController?.value.isInitialized ?? false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(color: Colors.white),
        title: customText(
          text: widget.title,
          color: Colors.white,
          fontSize: 20.sp,
        ),
      ),

      body: ListView(
        children: [
          size20h,

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPlayerArea(context, playerReady),
            ),
          ),

          size20h,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: widget.title,
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                size10h,

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: customText(
                    text: categoryName,
                    color: Colors.white,
                    fontSize: 15.sp,
                  ),
                ),

                size20h,

                customText(
                  text: "Description",
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                size10h,

                customText(
                  text: widget.description,
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ],
            ),
          ),

          if (widget.categoryId.isNotEmpty) ...[
            size30h,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: customText(
                text: "More Like This",
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            size10h,
            moreVideos.isEmpty
                ? Center(
                  child: customText(
                    text: "No similar videos",
                    color: Colors.white,
                  ),
                )
                : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: moreVideos.length,
                  itemBuilder: (context, index) {
                    final v = moreVideos[index];

                    return InkWell(
                      onTap: () {
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            v.resolvedThumbnail.isEmpty
                                ? Container(color: Colors.grey.shade800)
                                : CachedNetworkImage(
                                  imageUrl: v.resolvedThumbnail,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    );
                  },
                ),
          ],

          size100h,
        ],
      ),
    );
  }

  Widget _buildPlayerArea(BuildContext context, bool playerReady) {
    if (widget.isLiveStream && _liveComingSoon) {
      return LiveComingSoonPlaceholder(thumbnailUrl: widget.thumbnail);
    }

    if (widget.videoUrl.isEmpty) {
      return Center(
        child: customText(
          text: "Video is not available",
          color: Colors.white70,
        ),
      );
    }

    if (_playerLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (!widget.isLiveStream && !playerReady) {
      return Center(
        child: customText(
          text: "Video is not available",
          color: Colors.white70,
        ),
      );
    }

    if (playerReady && _chewieController != null) {
      if (widget.isLiveStream) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          child: Chewie(controller: _chewieController!),
        );
      }
      return Chewie(controller: _chewieController!);
    }

    return Center(
      child: customText(text: "Video is not available", color: Colors.white70),
    );
  }
}
