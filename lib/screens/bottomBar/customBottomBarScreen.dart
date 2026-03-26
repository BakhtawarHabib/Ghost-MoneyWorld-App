import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/ads/adsService.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
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
  late TabController tabController;
  late int currentPage;

  final List<Widget> pages = [
    const HomeScreen(),
    // const ComingSoonPage(),
    CategoriesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdsService.loadBanner();
    currentPage = widget.currentIndex;
    tabController = TabController(
      length: pages.length,
      vsync: this,
      initialIndex: currentPage,
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      setState(() {
        currentPage = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
        offset: 10,
        barColor: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        width: Get.width,
        barAlignment: Alignment.bottomCenter,
        body:
            (context, controller) => TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              dragStartBehavior: DragStartBehavior.down,
              children: pages,
            ),

        child: SizedBox(
          height: 68.h,
          width: Get.width,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              SvgPicture.asset(
                "assets/images/home_icon.svg",
                color:
                    currentPage == 0
                        ? AppColors.whiteFFFFFF
                        : AppColors.black323536,
                height: 24.h,
                width: 24.w,
              ),
              // SvgPicture.asset(
              //   "assets/images/live_icon.svg",
              //   color:
              //       currentPage == 1
              //           ? AppColors.whiteFFFFFF
              //           : AppColors.black323536,
              //   height: 24.h,
              //   width: 24.w,
              // ),
              Image.asset(
                "assets/images/categories.png",
                color:
                    currentPage == 2
                        ? AppColors.whiteFFFFFF
                        : AppColors.black323536,
                height: 24.h,
                width: 24.w,
              ),
              SvgPicture.asset(
                "assets/images/setting-2.svg",
                color:
                    currentPage == 3
                        ? AppColors.whiteFFFFFF
                        : AppColors.black323536,
                height: 24.h,
                width: 24.w,
              ),
            ],
          ),
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
    );
  }
}
