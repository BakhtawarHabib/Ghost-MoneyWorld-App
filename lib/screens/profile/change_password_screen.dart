import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/forgot_password_screen.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';
import 'package:ghost_money_world/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _auth = AuthService();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Success',
        'Your password has been updated.',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'wrong-password' => 'Current password is incorrect.',
        'weak-password' => 'New password is too weak.',
        _ => e.message ?? 'Could not update password',
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
        'Something went wrong',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Change password',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              size20h,
              AuthInputField(
                controller: _current,
                hintText: 'Current password',
                isPassword: true,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Required';
                  return null;
                },
              ),
              size16h,
              AuthInputField(
                controller: _next,
                hintText: 'New password',
                isPassword: true,
                validator: (v) {
                  final t = (v ?? '');
                  if (t.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              size16h,
              AuthInputField(
                controller: _confirm,
                hintText: 'Confirm new password',
                isPassword: true,
                validator: (v) {
                  if (v != _next.text) return 'Passwords do not match';
                  return null;
                },
              ),
              size12h,
              TextButton(
                onPressed: () => Get.to(
                  () => ForgotPasswordScreen(
                    initialEmail: _auth.currentUser?.email,
                  ),
                ),
                child: customText(
                  text: 'Forgot your current password?',
                  color: AppColors.primaryColor,
                  decoration: TextDecoration.underline,
                  fontSize: 13.sp,
                ),
              ),
              size20h,
              AuthPrimaryButton(
                title: 'Update password',
                loading: _loading,
                onTap: _submit,
              ),
              size40h,
            ],
          ),
        ),
      ),
    );
  }
}
