import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';

void showLoaderDialog(BuildContext context) {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: SpinKitFadingCircle(color: AppColors.primaryColor, size: 60.0),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoaderDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}
