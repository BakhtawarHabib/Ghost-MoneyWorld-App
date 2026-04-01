import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/authController.dart';
import 'package:ghost_money_world/screens/authScreens/loginScreen.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GetBuilder<AuthController>(
          builder: (ctrl) {
            return Form(
              key: formKey,
              child: Column(
                children: [
                  size20h,
                  Image.asset('assets/images/logo.png', height: 100.h),
                  size24h,
                  AuthInputField(
                    controller: ctrl.signUpNameController,
                    hintText: 'Full Name',
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Name is required';
                      if (text.length < 2) return 'Enter valid name';
                      return null;
                    },
                  ),
                  size15h,
                  AuthInputField(
                    controller: ctrl.signUpEmailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Email is required';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(text))
                        return 'Enter valid email';
                      return null;
                    },
                  ),
                  size15h,
                  AuthInputField(
                    controller: ctrl.signUpPasswordController,
                    hintText: 'Password',
                    isPassword: true,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Password is required';
                      if (text.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  size15h,
                  AuthInputField(
                    controller: ctrl.signUpConfirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Confirm password is required';
                      if (text != ctrl.signUpPasswordController.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  size20h,
                  AuthPrimaryButton(
                    title: 'Create Account',
                    loading: ctrl.signUpLoading,
                    onTap: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ctrl.signUp();
                      }
                    },
                  ),
                  size20h,
                  GestureDetector(
                    onTap: () => Get.off(() => const LoginScreen()),
                    child: customText(
                      text: "Already have an account? Login",
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  size30h,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
