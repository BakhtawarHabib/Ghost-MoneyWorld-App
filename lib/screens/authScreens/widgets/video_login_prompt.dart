import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/loginScreen.dart';
import 'package:ghost_money_world/screens/authScreens/signUpScreen.dart';
import 'package:ghost_money_world/services/auth_service.dart';

class VideoLoginPrompt {
  static final AuthService _authService = AuthService();

  static Future<void> _showPrompt({
    required String message,
    required VoidCallback onGuestContinue,
  }) async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: "Login required",
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              const SizedBox(height: 8),
              customText(text: message, color: Colors.white70),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const SignUpScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // SizedBox(
              //   width: double.infinity,
              //   child: TextButton(
              //     onPressed: () async {
              //       await _authService.signInAsGuest();
              //       Get.back();
              //       onGuestContinue();
              //     },
              //     child: const Text("Sign In as Guest"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Future<void> guardVideoAccess({
    required VoidCallback onAuthorized,
  }) async {
    final user = _authService.currentUser;
    if (user != null && !user.isAnonymous) {
      onAuthorized();
      return;
    }

    await _showPrompt(
      message: "Please login first to watch this video.",
      onGuestContinue: onAuthorized,
    );
  }

  static Future<void> guardFeedInteraction({
    required VoidCallback onAuthorized,
  }) async {
    final user = _authService.currentUser;
    if (user != null && !user.isAnonymous) {
      onAuthorized();
      return;
    }

    await _showPrompt(
      message: "Please login first to like or comment on feed videos.",
      onGuestContinue: () {},
    );
  }

  static Future<void> guardFeedUpload({
    required Future<void> Function() onAuthorized,
  }) async {
    final user = _authService.currentUser;
    if (user != null && !user.isAnonymous) {
      await onAuthorized();
      return;
    }

    await _showPrompt(
      message: "Please login first to upload feed videos.",
      onGuestContinue: () {},
    );
  }

  static Future<void> guardEditProfileAccess({
    required VoidCallback onAuthorized,
  }) async {
    final user = _authService.currentUser;
    if (user != null && !user.isAnonymous) {
      onAuthorized();
      return;
    }

    await _showPrompt(
      message: "Please login first to edit your profile.",
      onGuestContinue: () {},
    );
  }
}
