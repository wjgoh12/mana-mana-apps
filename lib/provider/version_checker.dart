import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';

class VersionChecker {
  static const String playStoreId = 'com.mana_mana_app ';
  static const String appStoreId = '6636538776';
  static const String huaweiAppId = 'C112273799';

  Future<bool> needsUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    if (Platform.isAndroid) {
      return await _checkPlayStore(currentVersion) ||
          await _checkHuaweiStore(currentVersion);
    } else if (Platform.isIOS) {
      return await _checkAppStore(currentVersion);
    }
    return false;
  }

  Future<bool> _checkPlayStore(String currentVersion) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://play.google.com/store/apps/details?id=$playStoreId&hl=en',
        ),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
        },
      );
      if (response.statusCode == 200) {
        final RegExp regex = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"\]\]');
        final match = regex.firstMatch(response.body);
        if (match != null) {
          final storeVersion = match.group(1)!;
          return _compareVersions(currentVersion, storeVersion);
        }
      }
    } catch (e) {
      // print('Play Store check error: $e');
    }
    return false;
  }

  Future<bool> _checkAppStore(String currentVersion) async {
    final response = await http.get(
      Uri.parse('http://itunes.apple.com/lookup?id=$appStoreId'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['results'].isNotEmpty) {
        String storeVersion = jsonResponse['results'][0]['version'];
        return _compareVersions(currentVersion, storeVersion);
      }
    }
    return false;
  }

  Future<bool> _checkHuaweiStore(String currentVersion) async {
    final response = await http.get(
      Uri.parse('https://appgallery.huawei.com/app/$huaweiAppId'),
    );
    if (response.statusCode == 200) {
      final RegExp regex = RegExp(r'Version\s*([\d.]+)');
      final match = regex.firstMatch(response.body);
      if (match != null) {
        return _compareVersions(currentVersion, match.group(1)!);
      }
    }
    return false;
  }

  bool _compareVersions(String currentVersion, String storeVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> store = storeVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < current.length && i < store.length; i++) {
      if (store[i] > current[i]) return true;
      if (store[i] < current[i]) return false;
    }
    return store.length > current.length;
  }

  void launchUpdate() async {
    String url = '';
    if (Platform.isAndroid) {
      // Check if device has Huawei Mobile Services
      bool isHms = await _checkHuaweiServices();
      url = isHms
          ? 'https://appgallery.huawei.com/app/$huaweiAppId'
          : 'https://play.google.com/store/apps/details?id=$playStoreId';
    } else if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/id$appStoreId';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> _checkHuaweiServices() async {
    final hmsChecker = HmsChecker();
    return await hmsChecker.isHmsAvailable();
  }
}

class HmsChecker {
  Future<bool> isHmsAvailable() async {
    try {
      final hmsApiAvailability = await HmsApiAvailability().isHMSAvailable();
      return hmsApiAvailability == 0; // 0 means HMS is available
    } catch (e) {
      return false;
    }
  }
}
