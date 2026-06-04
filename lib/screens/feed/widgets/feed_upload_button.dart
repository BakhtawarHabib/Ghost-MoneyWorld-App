import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghost_money_world/constants/app_colors.dart';

/// Gold circular upload button used in feed actions and bottom bar.
class FeedUploadButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final bool elevated;

  const FeedUploadButton({
    super.key,
    required this.onTap,
    this.size = 48,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = size.r;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow:
                elevated
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            Icons.add,
            color: AppColors.black000000,
            size: (size * 0.58).sp,
          ),
        ),
      ),
    );
  }
}
