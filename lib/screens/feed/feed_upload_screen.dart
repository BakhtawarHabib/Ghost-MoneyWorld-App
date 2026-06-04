import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/constants/app_colors.dart';
import 'package:ghost_money_world/constants/text_helper.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/services/feed_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class FeedUploadScreen extends StatefulWidget {
  const FeedUploadScreen({super.key});

  @override
  State<FeedUploadScreen> createState() => _FeedUploadScreenState();
}

class _FeedUploadScreenState extends State<FeedUploadScreen> {
  final FeedApi _api = FeedApi();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  File? _videoFile;
  VideoPlayerController? _previewController;
  bool _previewLoading = false;
  bool _uploading = false;
  String _status = '';
  double _progress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    if (_uploading) return;
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _previewLoading = true;
      _videoFile = File(picked.path);
    });

    await _previewController?.dispose();
    _previewController = null;

    final controller = VideoPlayerController.file(_videoFile!);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _previewController = controller;
      await controller.play();
      setState(() {
        _previewLoading = false;
      });
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _previewLoading = false;
        _videoFile = null;
      });
      Get.snackbar(
        'Preview failed',
        'Could not load this video. Try another file.',
      );
    }
  }

  void _togglePreviewPlayback() {
    final c = _previewController;
    if (c == null || !c.value.isInitialized) return;
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    setState(() {});
  }

  Future<void> _submit() async {
    await VideoLoginPrompt.guardFeedUpload(onAuthorized: _performUpload);
  }

  Future<void> _performUpload() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Title required', 'Add a title for your video');
      return;
    }
    if (_videoFile == null) {
      Get.snackbar('Video required', 'Select a vertical video to upload');
      return;
    }

    setState(() {
      _uploading = true;
      _status = 'Starting…';
      _progress = 0;
    });
    _previewController?.pause();

    try {
      await _api.uploadFeedVideo(
        file: _videoFile!,
        title: title,
        description: _descriptionController.text.trim(),
        onStep: (step) => setState(() => _status = step),
        onUploadProgress: (sent, total) {
          if (total <= 0) return;
          setState(() => _progress = sent / total);
        },
      );
      if (!mounted) return;
      Get.back(result: true);
      Get.snackbar(
        'Uploaded',
        'Your video will appear in the feed shortly.',
        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.9),
        colorText: Colors.black,
      );
    } on FeedApiException catch (e) {
      Get.snackbar('Upload failed', e.message);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _status = '';
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: customText(text: 'Upload to Feed', color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVideoPreview(),
            SizedBox(height: 20.h),

            SizedBox(height: 16.h),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Title *'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Description (optional)'),
            ),
            if (_uploading) ...[
              SizedBox(height: 20.h),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                color: AppColors.primaryColor,
                backgroundColor: Colors.white12,
              ),
              SizedBox(height: 8.h),
              customText(text: _status, color: Colors.white70, fontSize: 13.sp),
            ],
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _uploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child:
                  _uploading
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                      : const Text(
                        'Upload to Feed',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.48;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_videoFile == null)
                  _buildEmptyPicker()
                else
                  _buildPlayerSurface(),
                if (_videoFile != null && !_uploading)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: _ChangeVideoChip(onTap: _pickVideo),
                  ),
                if (_videoFile != null &&
                    _previewController != null &&
                    _previewController!.value.isInitialized &&
                    !_previewController!.value.isPlaying &&
                    !_previewLoading)
                  Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 56.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPicker() {
    return Material(
      color: const Color(0xff141414),
      child: InkWell(
        onTap: _pickVideo,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_camera_back_outlined,
                size: 48.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 12.h),
              customText(
                text: 'Tap to choose video',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
              SizedBox(height: 6.h),
              customText(
                text: '9:16 vertical recommended',
                color: Colors.white54,
                fontSize: 12.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSurface() {
    if (_previewLoading ||
        _previewController == null ||
        !_previewController!.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xff141414),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    final c = _previewController!;
    return GestureDetector(
      onTap: _togglePreviewPlayback,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ChangeVideoChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ChangeVideoChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz, color: Colors.white, size: 16.sp),
              SizedBox(width: 4.w),
              customText(
                text: 'Change',
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
