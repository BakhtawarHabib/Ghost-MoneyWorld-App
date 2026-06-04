import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/ads/adsService.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/screens/feed/feed_controller.dart';
import 'package:ghost_money_world/screens/feed/feed_screen.dart';
import 'package:ghost_money_world/screens/feed/feed_upload_flow.dart';
import 'package:ghost_money_world/screens/feed/widgets/feed_upload_button.dart';
import 'package:ghost_money_world/screens/homeScreen.dart';
import 'package:ghost_money_world/screens/profile/profileScreen.dart';
import 'package:ghost_money_world/screens/categories/categoriesScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:svg_flutter/svg.dart';

class CustomBottomBarScreen extends StatefulWidget {
  final int currentIndex;

  const CustomBottomBarScreen({Key? key, this.currentIndex = 0})
    : super(key: key);

  @override
  State<CustomBottomBarScreen> createState() => _CustomBottomBarScreenState();
}

class _CustomBottomBarScreenState extends State<CustomBottomBarScreen>
    with SingleTickerProviderStateMixin {
  static const int _feedTabIndex = 1;
  late TabController tabController;
  late int currentPage;
  bool _isBannerLoaded = false;
  static const int _tabCount = 4;

  @override
  void initState() {
    super.initState();
    currentPage = widget.currentIndex;
    tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: currentPage,
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      _syncFeedTabVisibility();
      setState(() {
        currentPage = tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFeedTabVisibility();
    });

    AdsService.loadInterstitial();
    AdsService.loadRewarded();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final width = MediaQuery.sizeOf(context).width;
      await AdsService.loadBanner(
        width: width,
        onLoaded: () {
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onFailedToLoad: (_) {
          if (!mounted) return;
          setState(() {
            _isBannerLoaded = false;
          });
        },
      );
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<FeedController>(tag: 'feed')) {
      Get.find<FeedController>(tag: 'feed').setTabVisible(false);
    }
    AdsService.disposeBanner();
    tabController.dispose();
    super.dispose();
  }

  void _syncFeedTabVisibility() {
    if (!Get.isRegistered<FeedController>(tag: 'feed')) return;
    final feedVisible = tabController.index == _feedTabIndex;
    Get.find<FeedController>(tag: 'feed').setTabVisible(feedVisible);
  }

  void _goToTab(int index) {
    if (tabController.index == index) return;
    tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBar(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        hideOnScroll: true,
        showIcon: false,
        reverse: false,
        offset: _isBannerLoaded ? 4 : 10,
        barColor: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        width: Get.width,
        barAlignment: Alignment.bottomCenter,
        body:
            (context, controller) => TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              dragStartBehavior: DragStartBehavior.down,
              children: [
                const HomeScreen(),
                const FeedScreen(),
                CategoriesScreen(),
                const ProfileScreen(),
              ],
            ),

        child: SizedBox(
          height: 68.h,
          width: Get.width,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(
                    onTap: () => _goToTab(0),
                    child: SvgPicture.asset(
                      'assets/images/home_icon.svg',
                      colorFilter: ColorFilter.mode(
                        currentPage == 0
                            ? AppColors.whiteFFFFFF
                            : AppColors.black323536,
                        BlendMode.srcIn,
                      ),
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                  _BottomNavItem(
                    onTap: () => _goToTab(1),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color:
                          currentPage == 1
                              ? AppColors.whiteFFFFFF
                              : AppColors.black323536,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 52.w),
                  _BottomNavItem(
                    onTap: () => _goToTab(2),
                    child: Image.asset(
                      'assets/images/categories.png',
                      color:
                          currentPage == 2
                              ? AppColors.whiteFFFFFF
                              : AppColors.black323536,
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                  _BottomNavItem(
                    onTap: () => _goToTab(3),
                    child: SvgPicture.asset(
                      'assets/images/setting-2.svg',
                      colorFilter: ColorFilter.mode(
                        currentPage == 3
                            ? AppColors.whiteFFFFFF
                            : AppColors.black323536,
                        BlendMode.srcIn,
                      ),
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -14.h,
                child: FeedUploadButton(
                  size: 52,
                  elevated: true,
                  onTap: FeedUploadFlow.open,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBanner(),
    );
  }

  Widget _buildBottomBanner() {
    final banner = AdsService.banner;
    if (!_isBannerLoaded || banner == null) {
      return const SizedBox.shrink();
    }
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: banner.size.height.toDouble(),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: banner.size.width.toDouble(),
              height: banner.size.height.toDouble(),
              child: AdWidget(ad: banner),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _BottomNavItem({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 68,
          child: Center(child: child),
        ),
      ),
    );
  }
}
