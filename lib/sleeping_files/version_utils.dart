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
