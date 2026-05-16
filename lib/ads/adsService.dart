import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ghost_money_world/ads/adsHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static bool _isInitialized = false;
  static BannerAd? banner;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;
  static bool _isInterstitialLoading = false;
  static bool _isRewardedLoading = false;
  /// When user requests an interstitial before one is loaded, run this after show (or on failure/timeout).
  static VoidCallback? _pendingInterstitialAfterShow;
  static Timer? _pendingInterstitialTimeout;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Loads a banner. Pass [width] (logical pixels) for anchored adaptive sizing (recommended on iOS).
  static Future<void> loadBanner({
    double? width,
    VoidCallback? onLoaded,
    void Function(LoadAdError error)? onFailedToLoad,
  }) async {
    await initialize();
    banner?.dispose();
    banner = null;

    AdSize size = AdSize.banner;
    if (width != null && width > 0) {
      final adaptive =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            width.truncate(),
          );
      if (adaptive != null) {
        size = adaptive;
      }
    }

    banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          banner = null;
          ad.dispose();
          onFailedToLoad?.call(error);
        },
      ),
    );

    banner!.load();
  }

  static void loadInterstitial() {
    if (_isInterstitialLoading || interstitialAd != null) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          interstitialAd = ad;
          final pending = _pendingInterstitialAfterShow;
          if (pending != null) {
            _pendingInterstitialAfterShow = null;
            _pendingInterstitialTimeout?.cancel();
            _pendingInterstitialTimeout = null;
            showInterstitial(pending);
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          interstitialAd = null;
          final pending = _pendingInterstitialAfterShow;
          if (pending != null) {
            _pendingInterstitialAfterShow = null;
            _pendingInterstitialTimeout?.cancel();
            _pendingInterstitialTimeout = null;
            pending();
          }
        },
      ),
    );
  }

  static void showInterstitial(VoidCallback afterAd) {
    _pendingInterstitialTimeout?.cancel();
    _pendingInterstitialTimeout = null;

    if (interstitialAd != null) {
      _pendingInterstitialAfterShow = null;
      final ad = interstitialAd!;
      interstitialAd = null;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitial();
          afterAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitial();
          afterAd();
        },
      );
      ad.show();
    } else {
      _pendingInterstitialTimeout?.cancel();
      _pendingInterstitialAfterShow = afterAd;
      loadInterstitial();
      _pendingInterstitialTimeout = Timer(const Duration(seconds: 10), () {
        if (_pendingInterstitialAfterShow == afterAd) {
          _pendingInterstitialAfterShow = null;
          _pendingInterstitialTimeout = null;
          afterAd();
        }
      });
    }
  }

  static void loadRewarded() {
    if (_isRewardedLoading || rewardedAd != null) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isRewardedLoading = false;
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedBeforePlay(VoidCallback onComplete) {
    if (rewardedAd != null) {
      final ad = rewardedAd!;
      rewardedAd = null;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewarded();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewarded();
          onComplete();
        },
      );
      ad.show(onUserEarnedReward: (ad, reward) {});
    } else {
      loadRewarded();
      onComplete();
    }
  }

  static void disposeBanner() {
    banner?.dispose();
    banner = null;
  }
}
