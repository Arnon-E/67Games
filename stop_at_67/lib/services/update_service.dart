import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.sixtysevengames.stop_at_67';

  /// Returns true if the store has a newer minimum required version.
  static Future<bool> isUpdateRequired() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults(const {'min_version': '0.0.0'});
      await remoteConfig.fetchAndActivate();

      final minVersion = remoteConfig.getString('min_version');
      final packageInfo = await PackageInfo.fromPlatform();
      return _isVersionLower(packageInfo.version, minVersion);
    } catch (_) {
      return false;
    }
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
    final parts = version.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}
