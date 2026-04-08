import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/models/categoryModel.dart';
import 'package:ghost_money_world/models/live_stream_model.dart';
import 'package:ghost_money_world/models/videoModel.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/categories/categoriesScreen.dart';
import 'package:ghost_money_world/screens/homeScreen/live_streams_controller.dart';
import 'package:ghost_money_world/screens/homeScreen/widgets/trending_creator_card.dart';
import 'package:ghost_money_world/screens/homeScreen/widgets/trending_hero_banner.dart';
import 'package:ghost_money_world/screens/profile/change_password_screen.dart';
import 'package:ghost_money_world/screens/profile/profileController.dart';
import 'package:ghost_money_world/screens/profile/profileScreen.dart';
import 'package:ghost_money_world/screens/settings/settingController.dart';
import 'package:ghost_money_world/screens/settings/settingPage.dart';
import 'package:ghost_money_world/screens/splash/videoDetailScreen.dart';
import 'package:ghost_money_world/ads/adsService.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/categories/categoriesController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileController profileController = Get.put(ProfileController());
  final CategoriesController categoriesController = Get.put(
    CategoriesController(),
  );
  final LiveStreamsController liveStreamsController = Get.put(
    LiveStreamsController(),
  );
  late final SettingPagesController settingPagesController =
      Get.isRegistered<SettingPagesController>()
          ? Get.find<SettingPagesController>()
          : Get.put(SettingPagesController());

  static const List<String> _trendingKeywords = [
    "trending now",
    "trending",
    "featured",
  ];

  VideoModel? _firstTrendingVideo(CategoriesController ctrl) {
    final trending = _findCategoryByKeywords(
      ctrl.categories,
      _trendingKeywords,
    );
    if (trending == null) return null;
    final list = ctrl.categoryVideos[trending.id] ?? [];
    if (list.isEmpty) return null;
    return list.first;
  }

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
      profileController.fetchProfile();
      settingPagesController.fetchData();
    });
    AdsService.loadInterstitial();
    AdsService.loadRewarded();
  }

  void _openVideoWithAd(VoidCallback onOpen) {
    AdsService.showInterstitial(onOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),

      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        leading: Builder(
          builder:
              (appBarContext) => IconButton(
                onPressed: () {
                  final scaffold = Scaffold.maybeOf(appBarContext);
                  if (scaffold != null && scaffold.hasDrawer) {
                    scaffold.openDrawer();
                  }
                },
                icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
              ),
        ),
        titleSpacing: 0,
        title: Image.asset('assets/images/logo.png', height: 34.h),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GetBuilder<ProfileController>(
              init:
                  Get.isRegistered<ProfileController>()
                      ? Get.find<ProfileController>()
                      : Get.put(ProfileController()),
              builder: (profileCtrl) {
                final avatar = profileCtrl.avatarImageProvider();
                return CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.white12,
                  backgroundImage: avatar,
                  child:
                      avatar == null
                          ? Icon(
                            Icons.person,
                            size: 20.sp,
                            color: Colors.white70,
                          )
                          : null,
                );
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          children: [
            GetBuilder<CategoriesController>(
              builder: (ctrl) {
                if (ctrl.loading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade800,
                          highlightColor: Colors.grey.shade700,
                          child: ColoredBox(color: Colors.grey.shade900),
                        ),
                      ),
                    ),
                  );
                }
                final first = _firstTrendingVideo(ctrl);
                if (first == null) {
                  return SizedBox(
                    height: 120.h,
                    child: Center(
                      child: customText(
                        text: "No featured video yet",
                        color: Colors.white70,
                      ),
                    ),
                  );
                }
                return TrendingHeroBanner(video: first);
              },
            ),

            size16h,

            GetBuilder<LiveStreamsController>(
              builder: (liveCtrl) {
                if (liveCtrl.loading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade800,
                      highlightColor: Colors.grey.shade700,
                      child: Container(
                        height: 136.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  );
                }
                if (liveCtrl.streams.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _LiveNowSection(
                  streams: liveCtrl.streams,
                  onVideoTapWithAd: _openVideoWithAd,
                );
              },
            ),

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

                final trending = _findCategoryByKeywords(
                  ctrl.categories,
                  _trendingKeywords,
                );

                final creatorSpotlight =
                    _findCategoryByKeywords(ctrl.categories, [
                      "creator spotlight",
                      "series / episodes",
                      "series",
                      "movies & shows",
                    ]);

                return Column(
                  children: [
                    if (trending != null)
                      _PosterStripSection(
                        title: "Trending Now",
                        videos: ctrl.categoryVideos[trending.id] ?? [],
                        onVideoTapWithAd: _openVideoWithAd,
                      ),

                    size15h,

                    if (creatorSpotlight != null)
                      _PosterStripSection(
                        title: "Creator Spotlight",
                        videos: ctrl.categoryVideos[creatorSpotlight.id] ?? [],
                        onVideoTapWithAd: _openVideoWithAd,
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF111111),
      child: SafeArea(
        child: GetBuilder<ProfileController>(
          init:
              Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>()
                  : Get.put(ProfileController()),
          builder: (profileCtrl) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 14.h),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white12, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.white12,
                        backgroundImage: profileCtrl.avatarImageProvider(),
                        child:
                            profileCtrl.avatarImageProvider() == null
                                ? Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 24.sp,
                                )
                                : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(
                              text:
                                  profileCtrl.name.isEmpty
                                      ? 'Ghost Money User'
                                      : profileCtrl.name,
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                            ),
                            SizedBox(height: 2.h),
                            customText(
                              text:
                                  profileCtrl.email.isEmpty
                                      ? 'Manage your account'
                                      : profileCtrl.email,
                              color: Colors.white70,
                              fontSize: 12.sp,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                _drawerTile(
                  icon: Icons.explore_outlined,
                  title: 'Discover',
                  onTap: () => Get.back(),
                ),
                _drawerTile(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  onTap: () {
                    Get.back();
                    Get.to(() => CategoriesScreen());
                  },
                ),
                _drawerTile(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    Get.back();
                    Get.to(() => const ProfileScreen());
                  },
                ),
                _drawerTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Get.back();
                    if (!profileCtrl.canChangePassword) {
                      VideoLoginPrompt.guardEditProfileAccess(
                        onAuthorized: () {},
                      );
                      return;
                    }
                    Get.to(() => const ChangePasswordScreen());
                  },
                ),
                _drawerTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Get.back();
                    Get.to(
                      () => SettingPage(
                        title: 'Privacy Policy',
                        text: settingPagesController.privacyText,
                      ),
                    );
                  },
                ),
                _drawerTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Get.back();
                    Get.to(
                      () => SettingPage(
                        title: 'Terms & Condition',
                        text: settingPagesController.termsText,
                      ),
                    );
                  },
                ),
                const Spacer(),
                const Divider(color: Colors.white12, height: 1),
                _drawerTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: Colors.redAccent,
                  onTap: () {
                    Get.back();
                    profileController.logout();
                  },
                ),
                SizedBox(height: 10.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color titleColor = Colors.white,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(icon, size: 21.sp, color: Colors.white70),
                SizedBox(width: 12.w),
                Expanded(
                  child: customText(
                    text: title,
                    color: titleColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white24, size: 20.sp),
              ],
            ),
          ),
        ),
      ),
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
  final List<LiveStreamModel> streams;
  final ValueChanged<VoidCallback>? onVideoTapWithAd;
  const _LiveNowSection({required this.streams, this.onVideoTapWithAd});

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
            itemCount: streams.length,
            itemBuilder: (context, index) {
              final stream = streams[index];
              final badgeText = 'LIVE';
              final badgeColor = stream.isLiveNow ? Colors.red : Colors.red;
              return GestureDetector(
                onTap: () {
                  onVideoTapWithAd?.call(() {
                    VideoLoginPrompt.guardVideoAccess(
                      onAuthorized: () {
                        Get.to(
                          () => VideoDetailPage(
                            id: stream.id,
                            title: stream.title,
                            description: stream.description,
                            categoryId: '',
                            videoUrl: stream.hlsUrl,
                            thumbnail: stream.thumbnailUrl,
                            isLiveStream: true,
                            liveStreamStatus: stream.status,
                          ),
                        );
                      },
                    );
                  });
                  if (onVideoTapWithAd == null) {
                    VideoLoginPrompt.guardVideoAccess(
                      onAuthorized: () {
                        Get.to(
                          () => VideoDetailPage(
                            id: stream.id,
                            title: stream.title,
                            description: stream.description,
                            categoryId: '',
                            videoUrl: stream.hlsUrl,
                            thumbnail: stream.thumbnailUrl,
                            isLiveStream: true,
                            liveStreamStatus: stream.status,
                          ),
                        );
                      },
                    );
                  }
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
                                  imageUrl: stream.thumbnailUrl,
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
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: customText(
                                    text: badgeText,
                                    color: Colors.white,
                                    fontSize: 12.sp,
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
                        text: stream.title,
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
        size15h,
      ],
    );
  }
}

class _PosterStripSection extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;
  final ValueChanged<VoidCallback>? onVideoTapWithAd;
  const _PosterStripSection({
    required this.title,
    required this.videos,
    this.onVideoTapWithAd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HomeSectionHeader(title: title),
        SizedBox(height: 10.h),
        SizedBox(
          height: 240.h,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: TrendingCreatorCard(
                  video: video,
                  onTap: () {
                    onVideoTapWithAd?.call(() {
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
                    });
                    if (onVideoTapWithAd == null) {
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
                    }
                  },
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
