import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/authController.dart';
import 'package:ghost_money_world/screens/authScreens/signUpScreen.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                  Image.asset('assets/images/logo.png', height: 120.h),
                  size30h,
                  AuthInputField(
                    controller: ctrl.loginEmailController,
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
                  size16h,
                  AuthInputField(
                    controller: ctrl.loginPasswordController,
                    hintText: 'Password',
                    isPassword: true,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Password is required';
                      if (text.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  size20h,
                  AuthPrimaryButton(
                    title: 'Login',
                    loading: ctrl.loginLoading,
                    onTap: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ctrl.login();
                      }
                    },
                  ),
                  size12h,
                  AuthPrimaryButton(
                    title: 'Sign In as Guest',
                    loading: ctrl.guestLoading,
                    onTap: ctrl.signInAsGuest,
                  ),
                  size20h,
                  GestureDetector(
                    onTap: () => Get.to(() => const SignUpScreen()),
                    child: customText(
                      text: "Don't have an account? Sign up",
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
