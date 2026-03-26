import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/screens/categories/categorySection.dart';
import 'package:ghost_money_world/screens/homeScreen/homeController.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/categories/categoriesController.dart';

class FeaturedController extends GetxController {}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(11.r),
    borderSide: const BorderSide(color: Colors.black),
  );

  final controller = Get.put(FeaturedController());
  // final ProfileController profileController = Get.put(ProfileController());
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );

  final PageController pageController = PageController();
  BannerController bannerController = Get.put(BannerController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // profileController.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        leading: Builder(
          builder:
              (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 30.h,
                    width: 30.w,
                  ),
                ),
              ),
        ),

        // title: SizedBox(
        //   height: 40.h,
        //   child: TextFormField(
        //     style: const TextStyle(color: Colors.white),
        //     decoration: InputDecoration(
        //       hintText: "Search",
        //       hintStyle: TextStyle(
        //         color: Colors.black,
        //         fontSize: 15.sp,
        //         fontFamily: 'Nunito',
        //       ),
        //       counterText: "",
        //       fillColor: AppColors.primaryColor,
        //       filled: true,
        //       contentPadding: EdgeInsets.only(top: 0, left: 10),
        //       border: _border(),
        //       enabledBorder: _border(),
        //       focusedBorder: _border(),
        //     ),
        //   ),
        // ),
        // actions: [
        //   GetBuilder<ProfileController>(
        //     builder: (ctrl) {
        //       return Padding(
        //         padding: const EdgeInsets.all(10.0),
        //         child:
        //             ctrl.photoUrl != null
        //                 ? ClipRRect(
        //                   borderRadius: BorderRadius.circular(100),
        //                   child: CachedNetworkImage(
        //                     imageUrl: ctrl.photoUrl!,
        //                     height: 50.h,
        //                     width: 50.h,
        //                     fit: BoxFit.cover,
        //                     placeholder:
        //                         (context, url) => Container(
        //                           height: 50.h,
        //                           alignment: Alignment.center,
        //                           child: const CircularProgressIndicator(
        //                             color: AppColors.primaryColor,
        //                           ),
        //                         ),
        //                     errorWidget:
        //                         (context, url, error) => Container(
        //                           height: 50.h,
        //                           width: 50.w,
        //                           decoration: const BoxDecoration(
        //                             shape: BoxShape.circle,
        //                             color: AppColors.primaryColor,
        //                           ),
        //                           child: Icon(
        //                             Icons.person,
        //                             size: 30.sp,
        //                             color: AppColors.black000000,
        //                           ),
        //                         ),
        //                   ),
        //                 )
        //                 : SizedBox(),
        //       );
        //     },
        //   ),
        // ],
      ),

      // drawer: Drawer(
      //   backgroundColor: Colors.black,
      //   child: ListView(
      //     children: <Widget>[
      //       GetBuilder<ProfileController>(
      //         builder: (ctrl) {
      //           return UserAccountsDrawerHeader(
      //             decoration: BoxDecoration(color: Colors.black),
      //             accountName: customText(
      //               text: ctrl.name ?? '',
      //               fontWeight: FontWeight.w700,
      //               fontSize: 16.sp,
      //             ),
      //             accountEmail: customText(
      //               text: ctrl.email ?? '',
      //               fontWeight: FontWeight.w500,
      //               fontSize: 13.sp,
      //             ),
      //             currentAccountPicture: CircleAvatar(
      //               backgroundColor: Colors.grey[300],
      //               backgroundImage:
      //                   (ctrl.photoUrl != null && ctrl.photoUrl!.isNotEmpty)
      //                       ? CachedNetworkImageProvider(ctrl.photoUrl!)
      //                       : const AssetImage("assets/images/logo.png")
      //                           as ImageProvider,
      //             ),
      //           );
      //         },
      //       ),

      //       ListTile(
      //         leading: SvgPicture.asset(
      //           "assets/images/account_icon.svg",
      //           color: AppColors.whiteFFFFFF,
      //           height: 22.h,
      //           width: 22.w,
      //         ),
      //         title: customText(
      //           text: "Profile",
      //           color: AppColors.whiteFFFFFF,
      //           fontSize: 16.sp,
      //         ),
      //       ),
      //       ListTile(
      //         leading: SvgPicture.asset(
      //           "assets/images/live_icon.svg",
      //           color: AppColors.whiteFFFFFF,
      //           height: 22.h,
      //           width: 22.w,
      //         ),
      //         title: customText(
      //           text: "Live",
      //           color: AppColors.whiteFFFFFF,
      //           fontSize: 16.sp,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        child: ListView(
          children: [
            GetBuilder<BannerController>(
              builder: (ctrl) {
                if (ctrl.loading) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade800,
                    highlightColor: Colors.grey.shade700,
                    child: Container(
                      width: Get.width,
                      height: 180.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: Colors.grey.shade900,
                      ),
                    ),
                  );
                }
                if (ctrl.bannerUrls.isEmpty) {
                  return SizedBox(
                    height: 180,
                    child: Center(
                      child: customText(
                        text: "No banners found",
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return FeaturedHeroBanner(
                  pageController: pageController,
                  urls: ctrl.bannerUrls,
                );
              },
            ),

            size40h,

            GetBuilder<CategoriesController>(
              builder: (ctrl) {
                if (ctrl.loading) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (ctrl.categories.isEmpty) {
                  return Center(
                    child: customText(
                      text: "No Categories Found",
                      color: Colors.white,
                    ),
                  );
                }

                final movies = ctrl.categories.firstWhereOrNull(
                  (c) => c.title == "Movies & Shows",
                );

                final trending = ctrl.categories.firstWhereOrNull(
                  (c) => c.title == "Featured / Trending",
                );

                return Column(
                  children: [
                    if (movies != null)
                      CategorySection(
                        title: movies.title,
                        videos: ctrl.categoryVideos[movies.id] ?? [],
                      ),

                    size20h,

                    if (trending != null)
                      CategorySection(
                        title: trending.title,
                        videos: ctrl.categoryVideos[trending.id] ?? [],
                      ),

                    size100h,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedHeroBanner extends StatelessWidget {
  final PageController pageController;
  final List<String> urls;

  const FeaturedHeroBanner({
    super.key,
    required this.pageController,
    required this.urls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: pageController,
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(urls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SmoothPageIndicator(
            controller: pageController,
            count: urls.length,
            effect: ExpandingDotsEffect(
              dotWidth: 8.0,
              dotHeight: 8.0,
              activeDotColor: Colors.white,
              dotColor: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: customText(
        text: title,
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class RegularGridList extends StatelessWidget {
  final List<String> slots;
  const RegularGridList({super.key, required this.slots});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder:
          (ctx, i) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage('assets/${slots[i]}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
    );
  }
}
