import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/models/categoryModel.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/homeScreen/homeController.dart';
import 'package:ghost_money_world/screens/splash/videoDetailScreen.dart';
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
  final controller = Get.put(FeaturedController());
  // final ProfileController profileController = Get.put(ProfileController());
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );

  final PageController pageController = PageController();
  BannerController bannerController = Get.put(BannerController());

  String _normalized(String value) => value.toLowerCase().trim();

  CategoryModel? _findCategoryByKeywords(
    List<CategoryModel> categories,
    List<String> keywords,
  ) {
    return categories.firstWhereOrNull((category) {
      final title = _normalized(category.title);
      return keywords.any((keyword) => title.contains(_normalized(keyword)));
    });
  }

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
        leading: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
        ),
        titleSpacing: 0,
        title: Image.asset('assets/images/logo.png', height: 34.h),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 15.r,
              backgroundImage: const AssetImage('assets/images/logo.png'),
            ),
          ),
        ],

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

            size16h,

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

                final live = _findCategoryByKeywords(ctrl.categories, [
                  "live now",
                  "live",
                  "livestream",
                ]);

                final trending = _findCategoryByKeywords(ctrl.categories, [
                  "trending now",
                  "trending",
                  "featured",
                ]);

                final creatorSpotlight =
                    _findCategoryByKeywords(ctrl.categories, [
                      "creator spotlight",
                      "series / episodes",
                      "series",
                      "movies & shows",
                    ]);

                final usedCategoryIds = {
                  if (live != null) live.id,
                  if (trending != null) trending.id,
                  if (creatorSpotlight != null) creatorSpotlight.id,
                };
                final continueCategory = ctrl.categories.firstWhereOrNull(
                  (c) => !usedCategoryIds.contains(c.id),
                );

                return Column(
                  children: [
                    if (live != null)
                      _LiveNowSection(
                        videos: ctrl.categoryVideos[live.id] ?? [],
                      ),

                    size15h,

                    if (trending != null)
                      _PosterStripSection(
                        title: "Trending Now",
                        videos: ctrl.categoryVideos[trending.id] ?? [],
                      ),

                    size15h,

                    if (creatorSpotlight != null)
                      _PosterStripSection(
                        title: "Creator Spotlight",
                        videos: ctrl.categoryVideos[creatorSpotlight.id] ?? [],
                      ),

                    size15h,

                    // if (continueCategory != null)
                    //   _ContinueWatchingSection(
                    //     videos: ctrl.categoryVideos[continueCategory.id] ?? [],
                    //   ),
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
          height: 220.h,
          child: PageView.builder(
            controller: pageController,
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(urls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customText(
                          text: "Watch Now",
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                        size8h,
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xfff4b304),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: customText(
                                text: "Watch Now",
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: customText(
                                text: "Add to List",
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
              dotColor: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  const _HomeSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customText(
            text: title,
            color: Colors.white,
            fontSize: 27.sp,
            fontWeight: FontWeight.w700,
          ),
          customText(text: "See All", color: Colors.white70, fontSize: 15.sp),
        ],
      ),
    );
  }
}

class _LiveNowSection extends StatelessWidget {
  final List<VideoModel> videos;
  const _LiveNowSection({required this.videos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HomeSectionHeader(title: "Live Now"),
        SizedBox(height: 10.h),
        SizedBox(
          height: 136.h,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () {
                  VideoLoginPrompt.guardVideoAccess(
                    onAuthorized: () {
                      Get.to(
                        () => VideoDetailPage(
                          id: video.id,
                          title: video.title,
                          description: video.description,
                          categoryId: video.category,
                          videoUrl: video.resolvedVideoUrl,
                          thumbnail: video.resolvedThumbnail,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 170.w,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: video.resolvedThumbnail,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (_, __, ___) => Container(
                                        color: Colors.grey.shade800,
                                      ),
                                ),
                              ),
                              Positioned(
                                left: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: customText(
                                    text: "LIVE",
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      customText(
                        text: video.title,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PosterStripSection extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;
  const _PosterStripSection({required this.title, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HomeSectionHeader(title: title),
        SizedBox(height: 10.h),
        SizedBox(
          height: 175.h,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () {
                  VideoLoginPrompt.guardVideoAccess(
                    onAuthorized: () {
                      Get.to(
                        () => VideoDetailPage(
                          id: video.id,
                          title: video.title,
                          description: video.description,
                          categoryId: video.category,
                          videoUrl: video.resolvedVideoUrl,
                          thumbnail: video.resolvedThumbnail,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 125.w,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: video.resolvedThumbnail,
                      fit: BoxFit.cover,
                      errorWidget:
                          (_, __, ___) =>
                              Container(color: Colors.grey.shade800),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueWatchingSection extends StatelessWidget {
  final List<VideoModel> videos;
  const _ContinueWatchingSection({required this.videos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _HomeSectionHeader(title: "Continue Watching"),
        SizedBox(height: 10.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children:
                videos.take(3).map((video) {
                  return GestureDetector(
                    onTap: () {
                      VideoLoginPrompt.guardVideoAccess(
                        onAuthorized: () {
                          Get.to(
                            () => VideoDetailPage(
                              id: video.id,
                              title: video.title,
                              description: video.description,
                              categoryId: video.category,
                              videoUrl: video.resolvedVideoUrl,
                              thumbnail: video.resolvedThumbnail,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff1b1b1b),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: video.resolvedThumbnail,
                              width: 120.w,
                              height: 54.h,
                              fit: BoxFit.cover,
                              errorWidget:
                                  (_, __, ___) =>
                                      Container(color: Colors.grey.shade800),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: customText(
                              text: video.title,
                              color: Colors.white,
                              maxLines: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
