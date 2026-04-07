import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';
import 'package:ghost_money_world/screens/profile/change_password_screen.dart';
import 'package:ghost_money_world/screens/profile/profileController.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: GetBuilder<ProfileController>(
          builder: (ctrl) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: ctrl.pickProfilePhoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52.r,
                        backgroundColor: const Color(0xff2b2b2b),
                        backgroundImage: ctrl.avatarImageProvider(),
                        child:
                            ctrl.avatarImageProvider() == null
                                ? Icon(
                                  Icons.person,
                                  size: 52.sp,
                                  color: Colors.white38,
                                )
                                : null,
                      ),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ctrl.hasPendingPhoto)
                  TextButton(
                    onPressed: ctrl.clearPendingPhoto,
                    child: customText(
                      text: 'Remove new photo',
                      color: Colors.white60,
                      fontSize: 12.sp,
                    ),
                  )
                else
                  SizedBox(height: 8.h),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: customText(
                    text: 'Email',
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff181818),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xff2b2b2b)),
                  ),
                  child: customText(
                    text: ctrl.email.isEmpty ? '—' : ctrl.email,
                    color: Colors.white54,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                AuthInputField(
                  controller: ctrl.nameController,
                  hintText: 'Full name',
                ),
                SizedBox(height: 14.h),
                AuthInputField(
                  controller: ctrl.phoneController,
                  hintText: 'Phone (optional)',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 14.h),
                AuthInputField(
                  controller: ctrl.bioController,
                  hintText: 'Bio (optional)',
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                ),

                SizedBox(height: 24.h),
                AuthPrimaryButton(
                  title: 'Save changes',
                  loading: ctrl.isSaving,
                  onTap: ctrl.saveProfile,
                ),
                SizedBox(height: 24.h),
              ],
            );
          },
        ),
      ),
    );
  }
}
