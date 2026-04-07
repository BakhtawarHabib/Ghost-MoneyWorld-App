import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/config/utils.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_input_field.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/auth_primary_button.dart';
import 'package:ghost_money_world/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  /// Prefill from login field when opened from login.
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _auth = AuthService();
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final pre = widget.initialEmail?.trim();
    if (pre != null && pre.isNotEmpty) {
      _email.text = pre;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(_email.text.trim());
      if (!mounted) return;
      Get.snackbar(
        'Check your email',
        'We sent a link to reset your password.',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Could not send reset email',
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
          'Forgot password',
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
              size24h,
              customText(
                text:
                    'Enter your account email and we\'ll send you a link to choose a new password.',
                color: Colors.white70,
                fontSize: 14.sp,
              ),
              size24h,
              AuthInputField(
                controller: _email,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Email is required';
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(text)) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 28.h),
              AuthPrimaryButton(
                title: 'Send reset link',
                loading: _loading,
                onTap: _submit,
              ),
              size24h,
            ],
          ),
        ),
      ),
    );
  }
}
