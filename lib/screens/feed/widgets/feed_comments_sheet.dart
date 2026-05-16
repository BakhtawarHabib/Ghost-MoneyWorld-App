import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/models/feed_comment.dart';
import 'package:ghost_money_world/models/feed_video.dart';
import 'package:ghost_money_world/screens/feed/feed_controller.dart';
import 'package:intl/intl.dart';

class FeedCommentsSheet extends StatefulWidget {
  final FeedVideo video;

  const FeedCommentsSheet({super.key, required this.video});

  @override
  State<FeedCommentsSheet> createState() => _FeedCommentsSheetState();
}

class _FeedCommentsSheetState extends State<FeedCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(FeedController controller) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await controller.postComment(widget.video.id, _controller.text);
    if (mounted) {
      _controller.clear();
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      tag: 'feed',
      builder: (controller) {
        final interactions = controller.interactionsFor(widget.video.id);
        final comments = interactions.comments;

        return Container(
          height: Get.height * 0.72,
          decoration: const BoxDecoration(
            color: Color(0xff111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: customText(
                        text:
                            '${interactions.commentCount} Comment${interactions.commentCount == 1 ? '' : 's'}',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child:
                    comments.isEmpty
                        ? Center(
                          child: customText(
                            text: 'No comments yet. Be the first!',
                            color: Colors.white54,
                          ),
                        )
                        : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return _CommentTile(comment: comments[index]);
                          },
                        ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: 300,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                            ),
                            counterStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xff1E1E1E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed:
                            _submitting ? null : () => _submit(controller),
                        icon:
                            _submitting
                                ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                                : const Icon(
                                  Icons.send_rounded,
                                  color: AppColors.primaryColor,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final FeedComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final created = comment.createdAt;
    final timeLabel =
        created == null ? '' : DateFormat('MMM d, h:mm a').format(created);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primaryColor.withOpacity(0.25),
          child: customText(
            text:
                comment.displayName.isNotEmpty
                    ? comment.displayName[0].toUpperCase()
                    : '?',
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: customText(
                      text: comment.displayName,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (timeLabel.isNotEmpty)
                    customText(
                      text: timeLabel,
                      color: Colors.white38,
                      fontSize: 11.sp,
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              customText(
                text: comment.text,
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
