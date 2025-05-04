import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  /// Gets the device model name
  static Future<String> getDeviceModel() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return webInfo.browserName.name;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.model;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Gets the OS version
  static Future<String> getOSVersion() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return webInfo.platform ?? 'Web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.systemVersion ?? 'iOS';
      } else {
        return defaultTargetPlatform.toString();
      }
    } catch (e) {
      return defaultTargetPlatform.toString();
    }
  }

  /// Gets the device platform information
  static Future<String> getDeviceInfo() async {
    if (kIsWeb) {
      return 'Web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS';
    } else {
      return defaultTargetPlatform.toString();
    }
  }

  /// Gets the app build number
  static Future<String> getBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (e) {
      return '';
    }
  }

  /// Gets all device and app information as a map
  static Future<Map<String, String>> getAllDeviceInfo() async {
    return {
      'deviceModel': await getDeviceModel(),
      'osVersion': await getOSVersion(),
      'device_info': await getDeviceInfo(),
      'installedBuildNumber': await getBuildNumber(),
    };
  }
} 