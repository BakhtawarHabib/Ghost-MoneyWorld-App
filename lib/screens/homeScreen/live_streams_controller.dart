import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/models/live_stream_model.dart';

class LiveStreamsController extends GetxController {
  List<LiveStreamModel> streams = [];
  bool loading = true;

  @override
  void onInit() {
    fetchLiveStreams();
    super.onInit();
  }

  Future<void> fetchLiveStreams() async {
    loading = true;
    update();
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('liveStreams')
              .orderBy('createdAt', descending: true)
              .get();

      streams =
          snap.docs
              .map((d) => LiveStreamModel.fromMap(d.data(), docId: d.id))
              .where((s) => s.canPlay)
              .toList();
    } catch (_) {
      // Missing index, permission, or orderBy field type — load without ordering.
      try {
        final snap =
            await FirebaseFirestore.instance.collection('liveStreams').get();
        streams =
            snap.docs
                .map((d) => LiveStreamModel.fromMap(d.data(), docId: d.id))
                .where((s) => s.canPlay)
                .toList();
      } catch (__) {
        streams = [];
      }
    } finally {
      loading = false;
      update();
    }
  }
}
