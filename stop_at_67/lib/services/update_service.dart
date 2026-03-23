import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.sixtysevengames.stop_at_67';

  static const _lastNotifiedBuildKey = 'stop_at_67_last_update_notified_build';

  /// Returns true if an update is required AND we haven't already shown the
  /// dialog for the current installed build.
  static Future<bool> isUpdateRequired() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Always fetch the latest value so changes in Firebase take effect
        // immediately on the next app launch rather than after a 1-hour cache.
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(const {'min_version': '0.0.0'});
      await remoteConfig.fetchAndActivate();

      final minVersion = remoteConfig.getString('min_version');
      final packageInfo = await PackageInfo.fromPlatform();

      // If current version already meets the requirement, no update needed.
      if (!_isVersionLower(packageInfo.version, minVersion)) return false;

      // If we already showed the dialog for this exact build, don't repeat it.
      // When the user actually installs a newer build the build number changes
      // and we check again.
      final prefs = await SharedPreferences.getInstance();
      final lastNotifiedBuild = prefs.getString(_lastNotifiedBuildKey);
      if (lastNotifiedBuild == packageInfo.buildNumber) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Call this after showing the update dialog so we don't repeat it for the
  /// same installed build.
  static Future<void> markUpdateDialogShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      await prefs.setString(_lastNotifiedBuildKey, packageInfo.buildNumber);
    } catch (_) {}
  }

  /// Returns true if [current] is strictly lower than [minimum].
  static bool _isVersionLower(String current, String minimum) {
    final c = _parse(current);
    final m = _parse(minimum);
    for (int i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  static List<int> _parse(String version) {
    // Strip build metadata (e.g. "+15") and pre-release tags (e.g. "-beta")
    // before splitting, so "1.0.3+15" or "1.0.3-beta" both parse as [1,0,3].
    final clean = version.split(RegExp(r'[+\-]')).first.trim();
    final parts = clean.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}
