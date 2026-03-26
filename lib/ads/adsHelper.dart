import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-7125228121147918/6974684375';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7125228121147918/9303502309';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-7125228121147918/6835740119';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7125228121147918/7044896820';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-7125228121147918/7170125490';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7125228121147918/6677338960';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
