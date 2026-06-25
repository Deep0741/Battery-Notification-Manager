import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants.dart';

class StartupService {
  bool _isInitialized = false;

  Future<void> init() async {
    if (!Platform.isWindows) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      launchAtStartup.setup(
        appName: packageInfo.appName.isNotEmpty ? packageInfo.appName : AppConstants.appName,
        appPath: Platform.resolvedExecutable,
      );
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing launch_at_startup: $e');
    }
  }

  Future<bool> isEnabled() async {
    if (!Platform.isWindows || !_isInitialized) return false;
    try {
      return await launchAtStartup.isEnabled();
    } catch (e) {
      debugPrint('Error checking startup enabled: $e');
      return false;
    }
  }

  Future<void> setLaunchAtStartup(bool enable) async {
    if (!Platform.isWindows || !_isInitialized) return;
    try {
      if (enable) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      debugPrint('Error modifying launch at startup registry: $e');
    }
  }
}
