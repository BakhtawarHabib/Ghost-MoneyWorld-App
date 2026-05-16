import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/profile/change_password_screen.dart';
import 'package:ghost_money_world/screens/profile/deleteAccountScreen.dart';
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
                    height: 200.h,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -36.h,
                    left: 20.w,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 44.r,
                        backgroundColor: AppColors.greyEDEDED,
                        backgroundImage:
                            controller.photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(
                                  controller.photoUrl,
                                )
                                : null,
                        child:
                            controller.photoUrl.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 44.sp,
                                  color: AppColors.black000000.withValues(
                                    alpha: 0.45,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 44.h),

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
              if (controller.phone.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
                  child: customText(
                    text: controller.phone,
                    fontSize: 13.sp,
                    color: Colors.black54,
                  ),
                ),
              if (controller.bio.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                  child: customText(
                    text: controller.bio,
                    fontSize: 13.sp,
                    color: Colors.black87,
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
                        profileTile(
                          () {
                            if (!controller.canChangePassword) {
                              VideoLoginPrompt.guardEditProfileAccess(
                                onAuthorized: () {},
                              );
                              return;
                            }
                            Get.to(() => const ChangePasswordScreen());
                          },
                          "assets/images/password.svg",
                          "Change Password",
                          iconColor: AppColors.black000000.withValues(
                            alpha: 0.8,
                          ),
                        ),

                        profileTile(
                          () {
                            VideoLoginPrompt.guardEditProfileAccess(
                              onAuthorized: () {
                                Get.to(() => const DeleteAccountScreen());
                              },
                            );
                          },
                          "assets/images/logout_icon.svg",
                          "Delete Account",
                          color: AppColors.redFF2B3A,
                        ),
                        profileTile(
                          controller.logout,
                          "assets/images/logout_icon.svg",
                          "Logout",
                          color: AppColors.black000000.withValues(alpha: 0.8),
                        ),
                        SizedBox(height: 20.h),

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
                        : ColorFilter.mode(iconColor, BlendMode.srcIn),
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
