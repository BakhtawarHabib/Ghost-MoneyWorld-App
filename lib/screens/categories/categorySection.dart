import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/splash/videoDetailScreen.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;

  const CategorySection({super.key, required this.title, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(
                  text: title,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                customText(
                  text: 'See All',
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            height: 145.h,
            child: ListView.builder(
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
                                color: Colors.grey.shade800,
                              )
                              : CachedNetworkImage(
                                imageUrl: video.resolvedThumbnail,
                                width: 115.w,
                                height: 145.h,
                                fit: BoxFit.cover,
                                placeholder:
                                    (_, __) => Container(
                                      width: 115.w,
                                      height: 145.h,
                                      color: Colors.grey.shade800,
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
