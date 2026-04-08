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

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  static void loadBanner({
    VoidCallback? onLoaded,
    void Function(LoadAdError error)? onFailedToLoad,
  }) {
    banner?.dispose();
    banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
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
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitial(VoidCallback afterAd) {
    if (interstitialAd != null) {
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
      loadInterstitial();
      afterAd();
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
