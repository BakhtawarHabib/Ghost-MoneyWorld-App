import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  List<String> bannerUrls = [];
  bool loading = true;

  @override
  void onInit() {
    fetchBanners();
    super.onInit();
  }

  Future<void> fetchBanners() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("banners")
          .orderBy("createdAt", descending: true)
          .get();

      bannerUrls.clear();

      for (var doc in snap.docs) {
        List<dynamic> urls = doc["urls"];
        for (var url in urls) {
          bannerUrls.add(url.toString());
        }
      }

      loading = false;
      update();
    } catch (e) {
      print("Error fetching banners: $e");
      loading = false;
      update();
    }
  }
}
