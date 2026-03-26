import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppStyles {
  static OutlineInputBorder textFieldOutlineBorder(context) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.sp),
        borderSide: BorderSide(width: 1, color: Colors.grey),
      );

  static Divider divider(context) => Divider(color: Colors.grey);

  BoxShadow boxShadow = BoxShadow(
    color: AppColors.black000000.withOpacity(0.3),
    spreadRadius: 2,
    blurRadius: 4,
    offset: const Offset(0, 1),
  );

  Radius bR20 = const Radius.circular(20);
  Radius bR00 = const Radius.circular(0);
}
