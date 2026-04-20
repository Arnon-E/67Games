import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const bool adsEnabled = true;

  // Your registered test device hashes — clicks/views from these devices are never
  // counted as real traffic, protecting your AdMob account from invalid traffic flags.
  // HOW TO FIND YOUR DEVICE HASH:
  //   1. Run the app on your phone in debug mode (flutter run)
  //   2. Run: adb logcat | grep "Use RequestConfiguration"
  //   3. Copy the hash from the printed message and add it to this list.
  static const List<String> _testDeviceIds = [
    // 'YOUR_DEVICE_HASH_HERE',  // e.g. 'B3AEABB7641E5A26598B5E8F2F3E1234'
  ];

  // TODO: Replace placeholder IDs with your real AdMob ad unit IDs from admob.google.com
  // Publisher ID: pub-6676728509237934
  static const _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Google test interstitial
      : 'ca-app-pub-6676728509237934/XXXXXXXXXX'; // TODO: your real Android interstitial ID

  static const _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Google test rewarded
      : 'ca-app-pub-6676728509237934/XXXXXXXXXX'; // TODO: your real Android rewarded ID

  static const _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Google test banner
      : 'ca-app-pub-6676728509237934/XXXXXXXXXX'; // TODO: your real Android banner ID

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!adsEnabled || _initialized) return;
    await MobileAds.instance.initialize();

    // Enforce G-rated (General Audiences) content to block adult/inappropriate ads.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: _testDeviceIds,
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
    if (!adsEnabled) return false;
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
    if (!adsEnabled) return false;
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

  /// Returns true when a single-player game count warrants an interstitial.
  static bool shouldShowAd(int gamesPlayed) =>
      gamesPlayed > 0 && gamesPlayed % 5 == 0;

  /// Returns true when a 1v1 match count warrants a between-session interstitial.
  /// Shows after every 3 completed multiplayer matches.
  static bool shouldShow1v1Ad(int matchesCompleted) =>
      matchesCompleted > 0 && matchesCompleted % 3 == 0;

  // ── Banner ads (matchmaking waiting screen) ───────────────────

  /// Create a banner ad pre-configured for the matchmaking screen.
  /// The caller must call [BannerAd.load] and dispose when done.
  BannerAd? createMatchmakingBanner({
    required void Function(Ad ad) onLoaded,
    required void Function(Ad ad, LoadAdError error) onFailedToLoad,
  }) {
    if (!adsEnabled) return null;
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailedToLoad,
      ),
    );
  }
}
