import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';
import 'package:ghost_money_world/screens/profile/profileController.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<ProfileController>(
          builder: (ctrl) {
            return Column(
              children: [
                AuthInputField(
                  controller: ctrl.nameController,
                  hintText: 'Full Name',
                ),
                SizedBox(height: 20.h),
                AuthPrimaryButton(
                  title: 'Save Changes',
                  loading: ctrl.isSaving,
                  onTap: ctrl.saveProfile,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
