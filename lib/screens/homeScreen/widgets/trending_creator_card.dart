import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/videoModel.dart';

/// Trending / Creator card: image fills the whole card; text sits on the image
/// with a bottom gradient. Corners are rounded so the frame reads slightly “bent”.
class TrendingCreatorCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const TrendingCreatorCard({
    super.key,
    required this.video,
    required this.onTap,
  });

  String get _subtitleLine {
    final d = video.description.trim();
    if (d.isEmpty) return 'Ghost Money World';
    final first = d.split(RegExp(r'[\n\r]')).first.trim();
    return first.length > 40 ? '${first.substring(0, 40)}…' : first;
  }

  String get _metaLine {
    if (video.duration.isNotEmpty) return video.duration;
    return 'Featured';
  }

  @override
  Widget build(BuildContext context) {
    final radius = 16.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: 162.w,
          height: 290.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed image (covers entire card height)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.06,
                    alignment: Alignment.center,
                    child:
                        video.resolvedThumbnail.isEmpty
                            ? Container(color: Colors.grey.shade900)
                            : CachedNetworkImage(
                              imageUrl: video.resolvedThumbnail,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder:
                                  (_, __) =>
                                      Container(color: Colors.grey.shade900),
                              errorWidget:
                                  (_, __, ___) =>
                                      Container(color: Colors.grey.shade800),
                            ),
                  ),
                ),
                // Bottom scrim so text reads on top of the image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.38, 0.58, 0.78, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.94),
                        ],
                      ),
                    ),
                  ),
                ),
                // Optional soft “bend”: vignette on sides (subtle barrel feel)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.05,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.12),
                        ],
                        stops: const [0.72, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        customText(
                          text: video.title.isEmpty ? 'Untitled' : video.title,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17.sp,
                          maxLines: 1,
                        ),
                        SizedBox(height: 3.h),
                        customText(
                          text: 'Latest video',
                          color: Colors.white,
                          fontSize: 11.sp,
                        ),
                        SizedBox(height: 2.h),
                        customText(
                          text: _subtitleLine,
                          color: Colors.white,
                          fontSize: 12.sp,
                          maxLines: 1,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.95,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.monetization_on_rounded,
                                size: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: customText(
                                text: _metaLine,
                                color: Colors.white,
                                fontSize: 11.sp,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: const BoxDecoration(
                                color: Color(0xffE53935),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            customText(
                              text: 'Watch',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
