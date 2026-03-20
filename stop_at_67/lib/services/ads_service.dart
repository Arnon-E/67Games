import 'dart:async';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';

class AdsService {
  // Replace these with your AppLovin MAX SDK key and ad unit IDs.
  // Get them from: applovin.com → MAX → Mediation → Ad Units
  static const _sdkKey = 'YOUR_APPLOVIN_SDK_KEY';

  static const _interstitialAdUnitId = kDebugMode
      ? 'YOUR_TEST_INTERSTITIAL_AD_UNIT_ID'
      : 'YOUR_PRODUCTION_INTERSTITIAL_AD_UNIT_ID';
  static const _rewardedAdUnitId = kDebugMode
      ? 'YOUR_TEST_REWARDED_AD_UNIT_ID'
      : 'YOUR_PRODUCTION_REWARDED_AD_UNIT_ID';

  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  Completer<bool>? _interstitialCompleter;
  Completer<bool>? _rewardedCompleter;
  void Function(MaxReward)? _onRewarded;

  Future<void> initialize() async {
    if (_initialized) return;
    await AppLovinMAX.initialize(_sdkKey);

    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        _interstitialReady = true;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _interstitialReady = false;
        Future.delayed(const Duration(seconds: 5), _preloadInterstitial);
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        _interstitialReady = false;
        _preloadInterstitial();
        _interstitialCompleter?.complete(false);
        _interstitialCompleter = null;
      },
      onAdHiddenCallback: (ad) {
        _interstitialReady = false;
        _preloadInterstitial();
        _interstitialCompleter?.complete(true);
        _interstitialCompleter = null;
      },
      onAdClickedCallback: (ad) {},
    ));

    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        _rewardedReady = true;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _rewardedReady = false;
        Future.delayed(const Duration(seconds: 5), _preloadRewarded);
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        _rewardedReady = false;
        _preloadRewarded();
        _rewardedCompleter?.complete(false);
        _rewardedCompleter = null;
        _onRewarded = null;
      },
      onAdHiddenCallback: (ad) {
        _rewardedReady = false;
        _preloadRewarded();
        // Only fires if reward was not already granted
        _rewardedCompleter?.complete(false);
        _rewardedCompleter = null;
        _onRewarded = null;
      },
      onAdClickedCallback: (ad) {},
      onAdReceivedRewardCallback: (ad, reward) {
        _onRewarded?.call(reward);
        _onRewarded = null;
        _rewardedCompleter?.complete(true);
        _rewardedCompleter = null;
      },
    ));

    _initialized = true;
    _preloadInterstitial();
    _preloadRewarded();
  }

  void _preloadInterstitial() {
    AppLovinMAX.loadInterstitial(_interstitialAdUnitId);
  }

  void _preloadRewarded() {
    AppLovinMAX.loadRewardedAd(_rewardedAdUnitId);
  }

  Future<bool> showInterstitial() async {
    if (!_initialized) await initialize();
    if (!_interstitialReady) {
      _preloadInterstitial();
      return false;
    }
    _interstitialCompleter = Completer<bool>();
    _interstitialReady = false;
    AppLovinMAX.showInterstitial(_interstitialAdUnitId);
    return _interstitialCompleter!.future;
  }

  Future<bool> showRewarded(void Function(MaxReward reward) onRewarded) async {
    if (!_initialized) await initialize();
    if (!_rewardedReady) {
      _preloadRewarded();
      return false;
    }
    _rewardedCompleter = Completer<bool>();
    _onRewarded = onRewarded;
    _rewardedReady = false;
    AppLovinMAX.showRewardedAd(_rewardedAdUnitId);
    return _rewardedCompleter!.future;
  }

  bool get isInterstitialReady => _interstitialReady;
  bool get isRewardedReady => _rewardedReady;

  static bool shouldShowAd(int gamesPlayed) =>
      gamesPlayed > 0 && gamesPlayed % 5 == 0;
}
