import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/feed/feed_controller.dart';
import 'package:ghost_money_world/screens/feed/widgets/feed_video_page.dart';
import 'package:shimmer/shimmer.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final controller = Get.put(FeedController(), tag: 'feed');
    controller.setTabVisible(true);
    _pageController = PageController();
  }

  @override
  void deactivate() {
    if (Get.isRegistered<FeedController>(tag: 'feed')) {
      Get.find<FeedController>(tag: 'feed').setTabVisible(false);
    }
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    if (Get.isRegistered<FeedController>(tag: 'feed')) {
      Get.find<FeedController>(tag: 'feed').setTabVisible(true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (Get.isRegistered<FeedController>(tag: 'feed')) {
      Get.delete<FeedController>(tag: 'feed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<FeedController>(
          tag: 'feed',
          builder: (controller) {
            if (controller.loading) {
              return _buildLoading();
            }

            if (controller.errorMessage != null) {
              return _buildError(controller);
            }

            if (controller.videos.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              color: AppColors.primaryColor,
              backgroundColor: Colors.black,
              onRefresh: () => controller.loadFeed(refresh: true),
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: controller.videos.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final video = controller.videos[index];
                  return FeedVideoPage(
                    key: ValueKey(video.id),
                    video: video,
                    isActive: controller.currentIndex == index,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xff1A1A1A),
      highlightColor: const Color(0xff2A2A2A),
      child: const ColoredBox(color: Colors.black),
    );
  }

  Widget _buildError(FeedController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48.sp),
            SizedBox(height: 12.h),
            customText(
              text: controller.errorMessage ?? 'Something went wrong',
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: controller.loadFeed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: customText(
          text: 'No feed videos yet.\nCheck back soon!',
          color: Colors.white70,
          textAlign: TextAlign.center,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
