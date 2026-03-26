import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  // TODO: Replace these test IDs with your real AdMob ad unit IDs from admob.google.com
  // Test App IDs are already set in AndroidManifest.xml / Info.plist
  static const _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Google test interstitial
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: your real Android interstitial ID

  static const _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Google test rewarded
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: your real Android rewarded ID

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();

    // Enforce G-rated (General Audiences) content to block adult/inappropriate ads.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      ),
    );

    _initialized = true;
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialReady = false;
          Future.delayed(const Duration(seconds: 5), _loadInterstitial);
        },
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedReady = false;
          Future.delayed(const Duration(seconds: 5), _loadRewarded);
        },
      ),
    );
  }

  Future<bool> showInterstitial() async {
    if (!_initialized) await initialize();
    if (!_interstitialReady || _interstitialAd == null) {
      _loadInterstitial();
      return false;
    }

    final completer = Completer<bool>();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        _loadInterstitial();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        _loadInterstitial();
        completer.complete(false);
      },
    );

    _interstitialReady = false;
    await _interstitialAd!.show();
    return completer.future;
  }

  Future<bool> showRewarded(void Function(dynamic reward) onRewarded) async {
    if (!_initialized) await initialize();
    if (!_rewardedReady || _rewardedAd == null) {
      _loadRewarded();
      return false;
    }

    final completer = Completer<bool>();
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        _loadRewarded();
        completer.complete(false);
      },
    );

    _rewardedReady = false;
    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        onRewarded(reward);
        completer.complete(true);
      },
    );
    return completer.future;
  }

  bool get isInterstitialReady => _interstitialReady;
  bool get isRewardedReady => _rewardedReady;

  static bool shouldShowAd(int gamesPlayed) =>
      gamesPlayed > 0 && gamesPlayed % 5 == 0;
}
