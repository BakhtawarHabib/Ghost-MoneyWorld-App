import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghost_money_world/constants/text_helper.dart';

/// Shown when a live Mux stream has no active broadcast yet (or playback fails).
class LiveComingSoonPlaceholder extends StatelessWidget {
  final String? thumbnailUrl;

  const LiveComingSoonPlaceholder({super.key, this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl?.trim() ?? '';
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.grey.shade900),
        if (url.isNotEmpty)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.55),
              colorBlendMode: BlendMode.darken,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          )
        else
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade900,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 48.sp,
                ),
                SizedBox(height: 12.h),
                customText(
                  text: 'Coming soon',
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                customText(
                  text:
                      'The host has not started this live stream yet. Check back shortly.',
                  color: Colors.white70,
                  fontSize: 14.sp,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
