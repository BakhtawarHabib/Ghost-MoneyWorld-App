import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/ads/adsService.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/categories/categoriesController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String videoUrl;
  final String thumbnail;

  const VideoDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.videoUrl,
    required this.thumbnail,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  String categoryName = "";
  List<VideoModel> moreVideos = [];

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadCategoryName();
    _loadMoreVideos();
  }

  Future<void> _initPlayer() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);

    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
    );

    setState(() {});
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
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerReady =
        _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized;

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

      bottomNavigationBar:
          AdsService.banner == null
              ? SizedBox.shrink()
              : Container(
                height: AdsService.banner!.size.height.toDouble(),
                color: Colors.white,
                child: AdWidget(ad: AdsService.banner!),
              ),
      body: ListView(
        children: [
          size20h,

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  playerReady
                      ? Chewie(controller: _chewieController!)
                      : Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
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
                    color: AppColors.primaryColor.withOpacity(0.25),
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
                          videoUrl: v.videoUrl,
                          thumbnail: v.thumbnail,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: v.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),

          size100h,
        ],
      ),
    );
  }
}
