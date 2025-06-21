import 'package:package_info_plus/package_info_plus.dart';

class VersionUtils {
  static PackageInfo? _packageInfo;

  /// Carica le informazioni del package una sola volta
  static Future<PackageInfo> getPackageInfo() async {
    if (_packageInfo == null) {
      _packageInfo = await PackageInfo.fromPlatform();
    }
    return _packageInfo!;
  }

  /// Ottiene la versione dell'app
  static Future<String> getVersion() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.version;
  }

  /// Ottiene il build number
  static Future<String> getBuildNumber() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.buildNumber;
  }

  /// Ottiene il nome dell'app
  static Future<String> getAppName() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.appName;
  }

  /// Ottiene il package name
  static Future<String> getPackageName() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.packageName;
  }

  /// Formatta la versione completa (es: "1.0.0+1")
  static Future<String> getFullVersion() async {
    final packageInfo = await getPackageInfo();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  /// Confronta due versioni e restituisce true se la prima è più nuova
  static bool isVersionNewer(String currentVersion, String newVersion) {
    final currentParts = _parseVersion(currentVersion);
    final newParts = _parseVersion(newVersion);

    for (int i = 0; i < newParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Parsa una stringa di versione in una lista di numeri
  static List<int> _parseVersion(String version) {
    // Rimuove eventuali suffissi come -alpha, -beta, ecc.
    final cleanVersion = version.split('-')[0];
    return cleanVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Ottiene informazioni dettagliate sulla versione
  static Future<Map<String, String>> getVersionInfo() async {
    final packageInfo = await getPackageInfo();
    return {
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'fullVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
    };
  }
}
