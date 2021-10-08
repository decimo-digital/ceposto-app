import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

/// Utility che recupera alcune informazioni relative al device
/// in uso
class DeviceInfo {
  /// Recupera l'UUID del device corrente
  static Future<String?> getDeviceUUID() async {
    String? platformVersion;

    try {
      if (Platform.isAndroid) {
        final deviceinfo = await DeviceInfoPlugin().androidInfo;
        platformVersion = deviceinfo.androidId;
      } else if (Platform.isIOS) {
        final deviceinfo = await DeviceInfoPlugin().iosInfo;
        platformVersion = deviceinfo.identifierForVendor;
      }
    } on PlatformException {
      platformVersion = null;
    }
    return platformVersion;
  }

  /// Restituisce il modello del device
  static Future<String?> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final deviceinfo = await DeviceInfoPlugin().androidInfo;
        return deviceinfo.model;
      } else if (Platform.isIOS) {
        final deviceinfo = await DeviceInfoPlugin().iosInfo;
        return deviceinfo.model;
      } else {
        return await getDeviceUUID();
      }
    } catch (_) {
      return getDeviceUUID();
    }
  }

  /// Restituisce la versione del sistema operativo
  static Future<String> getSdk() async {
    if (Platform.isAndroid) {
      return '${(await DeviceInfoPlugin().androidInfo).version.sdkInt}';
    } else if (Platform.isIOS) {
      return (await DeviceInfoPlugin().iosInfo).systemVersion;
    }
    return '';
  }

  /// Restituisce il numero di build del pacchetto installato
  static Future<String> getBuildVersion() async =>
      (await PackageInfo.fromPlatform()).version;
}
