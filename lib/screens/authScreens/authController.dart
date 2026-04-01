import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/screens/bottomBar/customBottomBarScreen.dart';
import 'package:ghost_money_world/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();

  bool loginLoading = false;
  bool signUpLoading = false;
  bool guestLoading = false;

  void _setLoginLoading(bool value) {
    loginLoading = value;
    update();
  }

  void _setSignUpLoading(bool value) {
    signUpLoading = value;
    update();
  }

  void _setGuestLoading(bool value) {
    guestLoading = value;
    update();
  }

  String? _validateEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'Email and password are required',
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }
    final emailError = _validateEmail(email);
    if (emailError != null) {
      Get.snackbar(
        'Validation',
        emailError,
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      Get.snackbar(
        'Validation',
        passwordError,
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }

    _setLoginLoading(true);
    try {
      await _authService.loginWithEmail(email: email, password: password);
      Get.offAll(() => const CustomBottomBarScreen(currentIndex: 0));
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.primaryColor,
      );
    } finally {
      _setLoginLoading(false);
    }
  }

  Future<void> signUp() async {
    final name = signUpNameController.text.trim();
    final email = signUpEmailController.text.trim();
    final password = signUpPasswordController.text.trim();
    final confirmPassword = signUpConfirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'All fields are required',
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }
    final emailError = _validateEmail(email);
    if (emailError != null) {
      Get.snackbar(
        'Validation',
        emailError,
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      Get.snackbar(
        'Validation',
        passwordError,
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar(
        'Password mismatch',
        'Confirm password must match password',
        backgroundColor: AppColors.primaryColor,
      );
      return;
    }

    _setSignUpLoading(true);
    try {
      await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      Get.offAll(() => const CustomBottomBarScreen(currentIndex: 0));
    } catch (e) {
      Get.snackbar(
        'Sign up failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.primaryColor,
      );
    } finally {
      _setSignUpLoading(false);
    }
  }

  Future<void> signInAsGuest() async {
    _setGuestLoading(true);
    try {
      await _authService.signInAsGuest();
      Get.offAll(() => const CustomBottomBarScreen(currentIndex: 0));
    } catch (e) {
      Get.snackbar(
        'Guest sign-in failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.primaryColor,
      );
    } finally {
      _setGuestLoading(false);
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    super.onClose();
  }
}
