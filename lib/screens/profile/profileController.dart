import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/screens/authScreens/loginScreen.dart';
import 'package:ghost_money_world/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final nameController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  String email = '';
  String name = '';
  bool isGuest = false;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  Future<void> fetchProfile() async {
    isLoading = true;
    update();
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      isGuest = user.isAnonymous;
      final data = await _authService.getProfile();
      name = (data?['name'] ?? user.displayName ?? '').toString();
      email = (data?['email'] ?? user.email ?? '').toString();
      nameController.text = name;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to load profile',
        backgroundColor: AppColors.primaryColor,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> saveProfile() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar(
        'Validation',
        'Name cannot be empty',
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }

    isSaving = true;
    update();
    try {
      await _authService.updateProfile(name: newName);
      name = newName;
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated',
        backgroundColor: AppColors.primaryColor,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: AppColors.primaryColor,
      );
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAll(() => const LoginScreen());
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
