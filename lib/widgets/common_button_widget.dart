import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';


class CommonButtonWidget extends StatefulWidget {
  final String title;
  final Function()? onTap;
  final double? fontSize;
  final double? borderRadius;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final Color? backGroundColor;
  final Color? textColor;
  final bool? isBorder;
  final bool? isShadow;

  const CommonButtonWidget({
    super.key,
    required this.title,
    this.onTap,
    this.fontSize,
    this.height,
    this.fontWeight,
    this.width,
    this.borderRadius,
    this.backGroundColor,
    this.textColor,
    this.isBorder,
    this.isShadow = true,
  });

  @override
  State<CommonButtonWidget> createState() => _CommonButtonWidgetState();
}

class _CommonButtonWidgetState extends State<CommonButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: widget.height ?? 60.h,
        width: widget.width ?? Get.width,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                widget.isBorder == true
                    ? AppColors.primaryColor
                    : Colors.transparent,
          ),
          color: widget.backGroundColor ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10.sp),

          boxShadow:
              widget.isShadow == true
                  ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(
                        0.31,
                      ), 
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4), 
                    ),
                  ]
                  : [], 
        ),
        alignment: Alignment.center,
        child: customText(
          text: widget.title,
          fontWeight: widget.fontWeight ?? FontWeight.w500,
          fontSize: widget.fontSize ?? 20.sp,
          color: widget.textColor ?? AppColors.whiteFFFFFF,
        ),
      ),
    );
  }
}

