import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/screens/authScreens/loginScreen.dart';
import 'package:ghost_money_world/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;
  String email = '';
  String name = '';
  String phone = '';
  String bio = '';
  String photoUrl = '';
  bool isGuest = false;

  File? _pendingPhotoFile;

  bool get hasPendingPhoto => _pendingPhotoFile != null;

  bool get canChangePassword => !isGuest && email.isNotEmpty;

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
      phone = (data?['phone'] ?? '').toString();
      bio = (data?['bio'] ?? '').toString();
      photoUrl = (data?['photoUrl'] ?? user.photoURL ?? '').toString().trim();

      nameController.text = name;
      phoneController.text = phone;
      bioController.text = bio;
      _pendingPhotoFile = null;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to load profile',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
    if (x == null) return;
    _pendingPhotoFile = File(x.path);
    update();
  }

  void clearPendingPhoto() {
    _pendingPhotoFile = null;
    update();
  }

  ImageProvider? avatarImageProvider() {
    if (_pendingPhotoFile != null) {
      return FileImage(_pendingPhotoFile!);
    }
    if (photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl);
    }
    return null;
  }

  Future<void> saveProfile() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar(
        'Validation',
        'Name cannot be empty',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    isSaving = true;
    update();
    try {
      String? uploadedUrl;
      if (_pendingPhotoFile != null) {
        uploadedUrl = await _authService.uploadProfilePhoto(
          file: _pendingPhotoFile!,
          userId: user.uid,
        );
        _pendingPhotoFile = null;
      }

      await _authService.updateProfile(
        name: newName,
        phone: phoneController.text.trim(),
        bio: bioController.text.trim(),
        photoUrl: uploadedUrl,
      );

      name = newName;
      phone = phoneController.text.trim();
      bio = bioController.text.trim();
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        photoUrl = uploadedUrl;
      }

      Get.back();
      // Get.snackbar(
      //   'Success',
      //   'Profile updated',
      //   backgroundColor: AppColors.primaryColor,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        e is FirebaseAuthException
            ? (e.message ?? 'Update failed')
            : 'Failed to update profile',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
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

  Future<void> deleteAccount() async {
    if (isDeleting) return;
    isDeleting = true;
    update();
    try {
      await _authService.deleteCurrentUserAccount();
      Get.offAll(() => const LoginScreen());
      Get.snackbar(
        'Account deleted',
        'Your account has been removed successfully.',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'requires-recent-login' =>
          'Please log in again, then try deleting your account.',
        'no-user' => 'No active user found.',
        _ => e.message ?? 'Could not delete account',
      };
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not delete account. Please try again.',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } finally {
      isDeleting = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
