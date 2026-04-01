import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/categories/categoriesController.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/splash/videoDetailScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesScreen extends StatelessWidget {
  final CategoriesController controller = Get.put(CategoriesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: customText(
          text: "Categories",
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
      ),
      body: GetBuilder<CategoriesController>(
        builder: (ctrl) {
          if (ctrl.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (ctrl.categories.isEmpty) {
            return Center(
              child: customText(
                text: "No Categories Found",
                color: Colors.white,
                fontSize: 18.sp,
              ),
            );
          }

          return ListView.builder(
            itemCount: ctrl.categories.length,
            itemBuilder: (context, index) {
              final category = ctrl.categories[index];
              final List<VideoModel> videos =
                  ctrl.categoryVideos[category.id] ?? [];

              return CategoryListSection(title: category.title, videos: videos);
            },
          );
        },
      ),
    );
  }
}

class CategoryListSection extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;

  const CategoryListSection({
    super.key,
    required this.title,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: customText(
              text: title,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          size10h,

          SizedBox(
            height: 145.h,
            child:
                videos.isEmpty
                    ? Center(
                      child: customText(text: "No Videos", color: Colors.white),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 15, left: 15),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                () => VideoDetailPage(
                                  title: video.title,
                                  description: video.description,
                                  categoryId: video.category,
                                  videoUrl: video.resolvedVideoUrl,
                                  thumbnail: video.resolvedThumbnail,
                                  id: video.id,
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  video.resolvedThumbnail.isEmpty
                                      ? Container(
                                        width: 115.w,
                                        height: 145.h,
                                        color: Colors.grey.shade700,
                                      )
                                      : CachedNetworkImage(
                                        imageUrl: video.resolvedThumbnail,
                                        width: 115.w,
                                        height: 145.h,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (_, __) => Shimmer.fromColors(
                                              baseColor: Colors.grey.shade800,
                                              highlightColor:
                                                  Colors.grey.shade700,
                                              child: Container(
                                                width: 115.w,
                                                height: 145.h,
                                                color: Colors.grey.shade900,
                                              ),
                                            ),
                                        errorWidget:
                                            (_, __, ___) => Container(
                                              width: 115.w,
                                              height: 145.h,
                                              color: Colors.grey.shade700,
                                            ),
                                      ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
