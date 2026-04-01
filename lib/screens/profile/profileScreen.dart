import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/profile/editProfileScreen.dart';
import 'package:ghost_money_world/screens/profile/profileController.dart';
import 'package:ghost_money_world/screens/settings/settingController.dart';
import 'package:ghost_money_world/screens/settings/settingPage.dart';
import 'package:svg_flutter/svg_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileController = Get.put(ProfileController());
  SettingPagesController pagesController = Get.put(SettingPagesController());
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      profileController.fetchProfile();
      pagesController.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                fit: StackFit.loose,
                children: [
                  Container(
                    height: 300.h,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Positioned(
                  //   bottom: -30,
                  //   left: 20.w,
                  //   child:
                  //       controller.photoUrl != null
                  //           ? ClipRRect(
                  //             borderRadius: BorderRadius.circular(100),
                  //             child: CachedNetworkImage(
                  //               imageUrl: controller.photoUrl!,
                  //               height: 80.h,
                  //               width: 80.h,
                  //               fit: BoxFit.cover,
                  //               placeholder:
                  //                   (context, url) => Container(
                  //                     height: 50.h,
                  //                     alignment: Alignment.center,
                  //                     child: const CircularProgressIndicator(
                  //                       color: AppColors.primaryColor,
                  //                     ),
                  //                   ),
                  //               errorWidget:
                  //                   (context, url, error) => Container(
                  //                     height: 80.h,
                  //                     width: 80.w,
                  //                     decoration: const BoxDecoration(
                  //                       shape: BoxShape.circle,
                  //                       color: AppColors.primaryColor,
                  //                     ),
                  //                     child: Icon(
                  //                       Icons.person,
                  //                       size: 50.sp,
                  //                       color: AppColors.black000000,
                  //                     ),
                  //                   ),
                  //             ),
                  //           )
                  //           : SizedBox(),
                  // ),
                ],
              ),

              size20h,
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: customText(
                  text: "Settings",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 25, right: 25),
              //   child: customText(
              //     text:
              //         controller.name?.isNotEmpty == true
              //             ? controller.name!
              //             : (controller.phone ?? ""),
              //     fontWeight: FontWeight.w600,
              //     fontSize: 20.sp,
              //   ),
              // ),

              // Padding(
              //   padding: const EdgeInsets.only(left: 25, right: 25),
              //   child: customText(
              //     text: controller.email ?? "",
              //     fontSize: 12.sp,
              //     color: Colors.grey[700],
              //   ),
              // ),
              size20h,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: customText(
                  text:
                      controller.name.isEmpty ? "Guest User" : controller.name,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: customText(
                  text: controller.email,
                  fontSize: 13.sp,
                  color: Colors.black54,
                ),
              ),
              if (controller.isGuest)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: customText(
                      text:
                          "You are using guest mode. Please login to update profile.",
                      color: Colors.black87,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              size10h,
              Expanded(
                child: GetBuilder<SettingPagesController>(
                  builder: (ctrl) {
                    return ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        profileTile(
                          () {
                            VideoLoginPrompt.guardEditProfileAccess(
                              onAuthorized: () {
                                Get.to(() => const EditProfileScreen());
                              },
                            );
                          },
                          "assets/images/account_icon.svg",
                          "Edit Profile",
                          iconColor: AppColors.black000000.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        profileTile(
                          () {
                            Get.to(
                              () => SettingPage(
                                title: "About App",
                                text: ctrl.aboutText,
                              ),
                            );
                          },
                          "assets/images/about_icon.svg",
                          "About App",
                          iconColor: AppColors.black000000.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        profileTile(
                          () {
                            Get.to(
                              () => SettingPage(
                                title: "Terms & Condition",
                                text: ctrl.termsText,
                              ),
                            );
                          },
                          "assets/images/terms_icon.svg",
                          "Terms & Condition",
                          iconColor: AppColors.black000000.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        profileTile(
                          () {
                            Get.to(
                              () => SettingPage(
                                title: "Privacy Policy",
                                text: ctrl.privacyText,
                              ),
                            );
                          },
                          "assets/images/privacy_policy.svg",
                          "Privacy Policy",
                          iconColor: AppColors.black000000.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        // profileTile(
                        //   () {
                        //     Get.to(() => const DeleteAccountScreen());
                        //   },
                        //   "assets/images/logout_icon.svg",
                        //   "Delete Account",
                        //   color: AppColors.redFF2B3A,
                        // ),
                        profileTile(
                          controller.logout,
                          "assets/images/logout_icon.svg",
                          "Logout",
                          color: AppColors.black000000.withValues(alpha: 0.8),
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: customText(
                            text: "Version 1.0.0",
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        size50h,
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget profileTile(
    VoidCallback onTap,
    String icon,
    String title, {
    Color? color,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.greyEDEDED.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                colorFilter:
                    iconColor == null
                        ? null
                        : ColorFilter.mode(iconColor!, BlendMode.srcIn),
              ),
              size10w,
              customText(
                text: title,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
