import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ghost_money_world/config/api_config.dart';
import 'package:ghost_money_world/models/feed_interactions.dart';
import 'package:ghost_money_world/models/feed_video.dart';
import 'package:ghost_money_world/screens/authScreens/widgets/video_login_prompt.dart';
import 'package:ghost_money_world/services/feed_api.dart';

class FeedController extends GetxController {
  final FeedApi _api = FeedApi();

  final List<FeedVideo> videos = [];
  final Map<String, FeedInteractions> interactionsByVideoId = {};
  final Set<String> _loadingInteractions = {};

  bool loading = true;
  String? errorMessage;
  int currentIndex = 0;
  bool tabVisible = false;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (!refresh) {
      loading = true;
      errorMessage = null;
      update();
    }

    try {
      final list = await _api.getFeed(limit: 20);
      videos
        ..clear()
        ..addAll(list);
      errorMessage = null;
      loading = false;
      update();

      if (videos.isNotEmpty) {
        await preloadInteractionsAround(0);
      }
    } on FeedApiException catch (e) {
      errorMessage = e.message;
      loading = false;
      update();
    } catch (_) {
      errorMessage = 'Failed to load feed';
      loading = false;
      update();
    }
  }

  void setTabVisible(bool visible) {
    if (tabVisible == visible) return;
    tabVisible = visible;
    update();
  }

  void onPageChanged(int index) {
    currentIndex = index;
    update();
    preloadInteractionsAround(index);
  }

  Future<void> preloadInteractionsAround(int index) async {
    final ids = <String>{};
    if (index >= 0 && index < videos.length) {
      ids.add(videos[index].id);
    }
    if (index + 1 < videos.length) {
      ids.add(videos[index + 1].id);
    }
    for (final id in ids) {
      await loadInteractions(id);
    }
  }

  Future<void> loadInteractions(String videoId) async {
    if (videoId.isEmpty || _loadingInteractions.contains(videoId)) return;
    _loadingInteractions.add(videoId);
    try {
      final data = await _api.getInteractions(videoId);
      interactionsByVideoId[videoId] = data;
      update();
    } catch (_) {
      // Keep UI usable if interactions fail for one video.
    } finally {
      _loadingInteractions.remove(videoId);
    }
  }

  FeedInteractions interactionsFor(String videoId) {
    return interactionsByVideoId[videoId] ?? const FeedInteractions();
  }

  Future<void> toggleLike(String videoId) async {
    await VideoLoginPrompt.guardFeedInteraction(
      onAuthorized: () async {
        final current = interactionsFor(videoId);
        final wasLiked = current.likedByMe;

        interactionsByVideoId[videoId] = current.copyWith(
          likedByMe: !wasLiked,
          likeCount: (current.likeCount + (wasLiked ? -1 : 1)).clamp(0, 999999),
        );
        update();

        try {
          if (wasLiked) {
            await _api.unlike(videoId);
          } else {
            await _api.like(videoId);
          }
          await loadInteractions(videoId);
        } on FeedApiException catch (e) {
          interactionsByVideoId[videoId] = current;
          update();
          Get.snackbar('Error', e.message);
        } catch (_) {
          interactionsByVideoId[videoId] = current;
          update();
          Get.snackbar('Error', 'Could not update like');
        }
      },
    );
  }

  Future<void> postComment(String videoId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await VideoLoginPrompt.guardFeedInteraction(
      onAuthorized: () async {
        try {
          final comment = await _api.comment(videoId, trimmed);
          final current = interactionsFor(videoId);
          final updatedComments = [comment, ...current.comments];
          interactionsByVideoId[videoId] = current.copyWith(
            commentCount: current.commentCount + 1,
            comments: updatedComments,
          );
          update();
        } on FeedApiException catch (e) {
          Get.snackbar('Error', e.message);
        } catch (_) {
          Get.snackbar('Error', 'Could not post comment');
        }
      },
    );
  }

  Future<void> shareVideo(FeedVideo video) async {
    final link = '${ApiConfig.baseUrl}/feed/${video.id}';
    final parts = <String>[];
    if (video.title.isNotEmpty) parts.add(video.title);
    if (video.description.isNotEmpty) parts.add(video.description);
    parts.add(link);
    final text = parts.join('\n\n');

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: video.title.isNotEmpty ? video.title : 'Ghost Money World',
      ),
    );

    try {
      await _api.trackShare(video.id);
      final current = interactionsFor(video.id);
      interactionsByVideoId[video.id] = current.copyWith(
        shareCount: current.shareCount + 1,
      );
      update();
    } catch (_) {
      // Share tracking is best-effort.
    }
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
