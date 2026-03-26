/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/authController.dart';
import 'package:ghost_money_world/widgets/customTextField.dart';

/*
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, toolbarHeight: 20.h),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: GetBuilder<AuthController>(
            builder: (controller) {
              return Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100.h,
                    fit: BoxFit.cover,
                  ),

                  GestureDetector(
                    onTap:
                        controller.isLoading
                            ? null
                            : controller.showImageSourceSheet,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45.r,
                          backgroundColor: Colors.white12,
                          backgroundImage:
                              controller.profileImageFile != null
                                  ? FileImage(controller.profileImageFile!)
                                  : (controller.profileImageUrl != null &&
                                      controller.profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(controller.profileImageUrl!)
                                      as ImageProvider
                                  : null,
                          child:
                              controller.profileImageFile == null &&
                                      (controller.profileImageUrl == null ||
                                          controller.profileImageUrl!.isEmpty)
                                  ? Icon(
                                    Icons.camera_alt,
                                    size: 30.sp,
                                    color: Colors.white70,
                                    )
                                  : null,
                        ),
                        size10h,
                        customText(
                          text: 'Add profile picture',
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),

                  size30h,
                  Customtextfield(
                    hintText: 'Name',
                    prefixSvgIcon: "assets/images/account_icon.svg",
                    controller: controller.nameController,
                  ),
                  size20h,
                  Customtextfield(
                    hintText: 'Email',
                    prefixSvgIcon: "assets/images/email_icon.svg",
                    controller: controller.registerEmailController,
                  ),
                  size20h,

                  Customtextfield(
                    hintText: 'Phone number (+1 USA)',
                    prefixSvgIcon: "assets/images/phone_icon.svg",
                    controller: controller.phoneController,
                  ),
                  size20h,

                  Customtextfield(
                    hintText: 'Password',
                    prefixSvgIcon: "assets/images/pass_icon.svg",
                    controller: controller.registerPasswordController,
                    isPassword: true,
                  ),
                  size20h,

                  Customtextfield(
                    hintText: 'Confirm Password',
                    prefixSvgIcon: "assets/images/pass_icon.svg",
                    controller: controller.confirmPasswordController,
                    isPassword: true,
                  ),
                  size30h,

                  GestureDetector(
                    onTap: controller.isLoading ? null : controller.signUp,
                    child: Container(
                      width: 382.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color:
                            controller.isLoading
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : AppColors.primaryColor,
                      ),
                      child: Center(
                        child:
                            controller.isLoading
                                ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                                : customText(
                                  text: 'Sign up',
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                  ),

                  size30h,

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        TextSpan(
                          text: 'Sign In now.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Nunito',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  size30h,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
*/*/
