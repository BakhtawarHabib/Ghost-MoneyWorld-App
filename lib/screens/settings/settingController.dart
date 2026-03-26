import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SettingPagesController extends GetxController {
  String aboutText = "";
  String privacyText = "";
  String termsText = "";

  bool loading = true;

  Future<void> fetchData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("app_settings").get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data.containsKey("about")) {
          aboutText = data["about"];
        }
        if (data.containsKey("privacyPolicy")) {
          privacyText = data["privacyPolicy"];
        }
        if (data.containsKey("termscondition")) {
          termsText = data["termscondition"];
        }
      }

      loading = false;
      update();
    } catch (e) {
      print("Error fetching settings: $e");
      loading = false;
      update();
    }
  }
}
