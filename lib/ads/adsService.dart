import 'package:ghost_money_world/ads/adsHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static BannerAd? banner;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;

  static void loadBanner() {
    banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("BANNER LOADED SUCCESSFULLY");
        },
        onAdFailedToLoad: (ad, error) {
          print("BANNER FAILED: ${error.message}");
          banner = null;
          ad.dispose();
        },
      ),
    );

    banner!.load();
  }

  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print("INTERSTITIAL LOADED");
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print("INTERSTITIAL FAILED: ${error.message}");
          interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitial(Function afterAd) {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          interstitialAd = null;
          loadInterstitial();
          afterAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          interstitialAd = null;
          loadInterstitial();
          afterAd();
        },
      );

      interstitialAd!.show();
    } else {
      loadInterstitial();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (interstitialAd != null) {
          showInterstitial(afterAd);
        } else {
          afterAd();
        }
      });
    }
  }

  static void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("REWARDED LOADED");
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print("REWARDED FAILED: ${error.message}");
          rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedBeforePlay(Function onComplete) {
    if (rewardedAd != null) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          rewardedAd = null;
          loadRewarded();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          rewardedAd = null;
          loadRewarded();
          onComplete();
        },
      );

      rewardedAd!.show(onUserEarnedReward: (ad, reward) {});

      rewardedAd = null;
    } else {
      loadRewarded();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (rewardedAd != null) {
          showRewardedBeforePlay(onComplete);
        } else {
          onComplete();
        }
      });
    }
  }
}
