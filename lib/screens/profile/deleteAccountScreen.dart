import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/profile/profileController.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final ProfileController profileController = Get.find<ProfileController>();
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: customText(
          text: 'Delete Account',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Icon
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: AppColors.redFF2B3A.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 50.sp,
                      color: AppColors.redFF2B3A,
                    ),
                  ),
                ),
                size30h,

                // Warning Title
                Center(
                  child: customText(
                    text: 'Are you sure?',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                size20h,

                // Warning Message
                customText(
                  text:
                      'This action cannot be undone. Deleting your account will permanently remove:',
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
                size20h,

                // What will be deleted
                _buildDeleteItem('Your account and profile information'),
                _buildDeleteItem('All videos you created'),
                _buildDeleteItem('All categories you created'),
                _buildDeleteItem('All associated files (thumbnails, videos)'),
                size30h,

                // Account Information
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(
                        text: 'Account Information',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      size10h,
                      if (controller.name.isNotEmpty)
                        _buildInfoRow('Name', controller.name),
                      if (controller.email.isNotEmpty)
                        _buildInfoRow('Email', controller.email),
                      if (controller.phone.isNotEmpty)
                        _buildInfoRow('Phone', controller.phone),
                    ],
                  ),
                ),
                size30h,

                // Confirmation Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isConfirmed,
                      onChanged: (value) {
                        setState(() {
                          _isConfirmed = value ?? false;
                        });
                      },
                      activeColor: AppColors.redFF2B3A,
                    ),
                    Expanded(
                      child: customText(
                        text:
                            'I understand that this action is permanent and cannot be undone.',
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                size30h,

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: controller.isDeleting || !_isConfirmed
                        ? null
                        : () => _showFinalConfirmation(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redFF2B3A,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : customText(
                            text: 'Delete My Account',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                  ),
                ),
                size20h,

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: controller.isDeleting ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: customText(
                      text: 'Cancel',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.remove, size: 16.sp, color: AppColors.redFF2B3A),
          size10w,
          Expanded(
            child: customText(
              text: text,
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: customText(
              text: '$label:',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: customText(
              text: value,
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmation(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: customText(
          text: 'Final Confirmation',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        content: customText(
          text:
              'Are you absolutely sure you want to delete your account? This action is permanent and cannot be reversed.',
          fontSize: 14.sp,
          color: Colors.black,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: customText(
              text: 'Cancel',
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: customText(
              text: 'Delete',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.redFF2B3A,
            ),
          ),
        ],
      ),
    );
  }
}

