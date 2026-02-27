import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  // Test ad unit IDs (replace with real ones for production)
  static const _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.pg,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: const ['EMULATOR'],
      ),
    );
    _initialized = true;
    _preloadInterstitial();
    _preloadRewarded();
  }

  void _preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialReady = true;
        },
        onAdFailedToLoad: (_) {
          _interstitialReady = false;
          Future.delayed(const Duration(seconds: 5), _preloadInterstitial);
        },
      ),
    );
  }

  void _preloadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedReady = true;
        },
        onAdFailedToLoad: (_) {
          _rewardedReady = false;
          Future.delayed(const Duration(seconds: 5), _preloadRewarded);
        },
      ),
    );
  }

  Future<bool> showInterstitial() async {
    if (!_initialized) await initialize();
    if (!_interstitialReady || _interstitial == null) {
      _preloadInterstitial();
      return false;
    }
    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _interstitialReady = false;
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _interstitialReady = false;
        _preloadInterstitial();
      },
    );
    await _interstitial!.show();
    return true;
  }

  Future<bool> showRewarded(void Function(RewardItem reward) onRewarded) async {
    if (!_initialized) await initialize();
    if (!_rewardedReady || _rewarded == null) {
      _preloadRewarded();
      return false;
    }
    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _rewardedReady = false;
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        _rewardedReady = false;
        _preloadRewarded();
      },
    );
    await _rewarded!.show(onUserEarnedReward: (_, reward) => onRewarded(reward));
    return true;
  }

  bool get isInterstitialReady => _interstitialReady;
  bool get isRewardedReady => _rewardedReady;

  static bool shouldShowAd(int gamesPlayed) =>
      gamesPlayed > 0 && gamesPlayed % 5 == 0;
}
