import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ghost_money_world/ads/adsService.dart';
import 'package:ghost_money_world/firebase_options.dart';
import 'package:ghost_money_world/ghostMoneyWorld.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await MobileAds.instance.initialize();
  AdsService.loadInterstitial();
  AdsService.loadRewarded();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GhostMoneyWorld());
}
