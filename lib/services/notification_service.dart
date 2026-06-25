import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import '../core/constants.dart';

class NotificationService {
  bool _isInitialized = false;

  Future<void> init() async {
    if (!Platform.isWindows) return;
    try {
      await localNotifier.setup(
        appName: AppConstants.appName,
        // Require shortcut creation so notifications show up reliably on Windows 10/11
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing local_notifier: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    VoidCallback? onTap,
    bool silent = false,
  }) async {
    if (!Platform.isWindows || !_isInitialized) return;

    try {
      final notification = LocalNotification(
        title: title,
        body: body,
        silent: silent, // If true, Windows won't play its default notification sound
      );

      if (onTap != null) {
        notification.onClick = onTap;
      }

      await notification.show();
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
