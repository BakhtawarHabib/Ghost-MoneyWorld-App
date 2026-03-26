import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Text customText({
  required String text,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  String? fontFamily,
  FontStyle? fontStyle,
  int? maxLines,
  TextDecoration? decoration,
  double? letterSpacing,
  Color? decorationColor,
}) {
  return Text(
    text,
    maxLines: maxLines,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
      color: color,
      fontSize: fontSize ?? 14.sp,
      fontStyle: fontStyle,
      fontFamily: 'Nunito',
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.0,
      decoration: decoration,
      decorationColor: decorationColor ?? Colors.white,
    ),
  );
}

Text customTextDMSans({
  required String text,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextAlign? textAlign,
  String? fontFamily,
  FontStyle? fontStyle,
  int? maxLines,
  TextDecoration? decoration,
  double? letterSpacing,
}) {
  return Text(
    text,
    maxLines: maxLines,
    textAlign: textAlign ?? TextAlign.start,
    style: TextStyle(
      color: color,
      fontSize: fontSize ?? 14.sp,
      fontStyle: fontStyle,
      fontFamily: 'DMSans',
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing ?? 0.0,
      decoration: decoration,
    ),
  );
}
