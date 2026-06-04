import 'package:get/get.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/screens/feed/feed_controller.dart';
import 'package:ghost_money_world/screens/feed/feed_upload_screen.dart';

class FeedUploadFlow {
  FeedUploadFlow._();

  static Future<void> open() async {
    await VideoLoginPrompt.guardFeedUpload(
      onAuthorized: () async {
        final refreshed = await Get.to<bool>(() => const FeedUploadScreen());
        if (refreshed == true && Get.isRegistered<FeedController>(tag: 'feed')) {
          await Get.find<FeedController>(tag: 'feed').loadFeed(refresh: true);
        }
      },
    );
  }
}
