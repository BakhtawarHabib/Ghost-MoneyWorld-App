import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ghost_money_world/models/categoryModel.dart';
import 'package:ghost_money_world/models/videoModel.dart';

class CategoriesController extends GetxController {
  List<CategoryModel> categories = [];
  Map<String, List<VideoModel>> categoryVideos = {};
  bool loading = true;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }


  Future<void> fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      categories =
          snapshot.docs.map((doc) {
            return CategoryModel.fromMap(doc.data());
          }).toList();

      for (var category in categories) {
        await fetchVideosByCategory(category.id);
      }

      loading = false;
      update();
    } catch (e) {
      print("Error fetching categories: $e");
      loading = false;
      update();
    }
  }


  Future<void> fetchVideosByCategory(String categoryId) async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection("videos")
              .where("category", isEqualTo: categoryId)
              .get();

      categoryVideos[categoryId] =
          snap.docs.map((doc) => VideoModel.fromMap(doc.data())).toList();

      update();
    } catch (e) {
      print("Error fetching videos for category $categoryId: $e");
    }
  }


  Future<String> getCategoryName(String categoryId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection("categories")
              .doc(categoryId)
              .get();

      return doc.exists ? doc["title"] : "Unknown Category";
    } catch (e) {
      print("Error getting category name: $e");
      return "Unknown Category";
    }
  }


  Future<List<VideoModel>> getVideosByCategory(String categoryId) async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection("videos")
              .where("category", isEqualTo: categoryId)
              .get();

      return snap.docs.map((doc) => VideoModel.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching similar videos: $e");
      return [];
    }
  }
}
