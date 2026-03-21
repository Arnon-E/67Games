import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsService {
  static const _gameId = '6070462';

  static const _interstitialPlacementId = 'Interstitial_Android';
  static const _rewardedPlacementId = 'Rewarded_Android';

  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _initialized = false;

  Completer<bool>? _interstitialCompleter;
  Completer<bool>? _rewardedCompleter;
  void Function()? _onRewarded;

  Future<void> initialize() async {
    if (_initialized) return;
    await UnityAds.init(
      gameId: _gameId,
      testMode: kDebugMode,
      onComplete: () {
        _initialized = true;
        _preloadInterstitial();
        _preloadRewarded();
      },
      onFailed: (error, message) {
        debugPrint('Unity Ads init failed: $error - $message');
      },
    );
  }

  void _preloadInterstitial() {
    UnityAds.load(
      placementId: _interstitialPlacementId,
      onComplete: (_) => _interstitialReady = true,
      onFailed: (_, error, message) {
        _interstitialReady = false;
        Future.delayed(const Duration(seconds: 5), _preloadInterstitial);
      },
    );
  }

  void _preloadRewarded() {
    UnityAds.load(
      placementId: _rewardedPlacementId,
      onComplete: (_) => _rewardedReady = true,
      onFailed: (_, error, message) {
        _rewardedReady = false;
        Future.delayed(const Duration(seconds: 5), _preloadRewarded);
      },
    );
  }

  Future<bool> showInterstitial() async {
    if (!_initialized) await initialize();
    if (!_interstitialReady) {
      _preloadInterstitial();
      return false;
    }
    _interstitialCompleter = Completer<bool>();
    _interstitialReady = false;
    UnityAds.showVideoAd(
      placementId: _interstitialPlacementId,
      onComplete: (_) {
        _preloadInterstitial();
        _interstitialCompleter?.complete(true);
        _interstitialCompleter = null;
      },
      onFailed: (_, error, message) {
        _preloadInterstitial();
        _interstitialCompleter?.complete(false);
        _interstitialCompleter = null;
      },
      onSkipped: (_) {
        _preloadInterstitial();
        _interstitialCompleter?.complete(true);
        _interstitialCompleter = null;
      },
      onStart: (_) {},
    );
    return _interstitialCompleter!.future;
  }

  Future<bool> showRewarded(void Function(dynamic reward) onRewarded) async {
    if (!_initialized) await initialize();
    if (!_rewardedReady) {
      _preloadRewarded();
      return false;
    }
    _rewardedCompleter = Completer<bool>();
    _onRewarded = () => onRewarded(null);
    _rewardedReady = false;
    UnityAds.showVideoAd(
      placementId: _rewardedPlacementId,
      onComplete: (_) {
        _onRewarded?.call();
        _onRewarded = null;
        _preloadRewarded();
        _rewardedCompleter?.complete(true);
        _rewardedCompleter = null;
      },
      onFailed: (_, error, message) {
        _onRewarded = null;
        _preloadRewarded();
        _rewardedCompleter?.complete(false);
        _rewardedCompleter = null;
      },
      onSkipped: (_) {
        _onRewarded = null;
        _preloadRewarded();
        _rewardedCompleter?.complete(false);
        _rewardedCompleter = null;
      },
      onStart: (_) {},
    );
    return _rewardedCompleter!.future;
  }

  bool get isInterstitialReady => _interstitialReady;
  bool get isRewardedReady => _rewardedReady;

  static bool shouldShowAd(int gamesPlayed) =>
      gamesPlayed > 0 && gamesPlayed % 5 == 0;
}
