import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService with TrayListener {
  VoidCallback? _onOpenDashboard;
  VoidCallback? _onEnablePerformanceMode;
  VoidCallback? _onDisablePerformanceMode;
  VoidCallback? _onExitApp;

  Timer? _flashTimer;
  bool _isFlashOn = false;
  bool _isFlashing = false;

  // Paths to icons
  // Note: These must be configured in pubspec.yaml assets section
  static const String _normalIconPath = 'assets/app_icon.ico';
  static const String _alertIconPath = 'assets/app_icon_alert.ico';
  
  // Windows-specific resource path if fallback is needed
  static const String _winIconPath = 'windows/runner/resources/app_icon.ico';

  Future<void> initTray({
    required VoidCallback onOpenDashboard,
    required VoidCallback onEnablePerformanceMode,
    required VoidCallback onDisablePerformanceMode,
    required VoidCallback onExitApp,
  }) async {
    if (!Platform.isWindows) return;

    _onOpenDashboard = onOpenDashboard;
    _onEnablePerformanceMode = onEnablePerformanceMode;
    _onDisablePerformanceMode = onDisablePerformanceMode;
    _onExitApp = onExitApp;

    try {
      trayManager.addListener(this);
      
      // Set the initial icon
      // If the custom asset is missing, tray_manager can fall back gracefully
      await _setIcon(_normalIconPath);

      // Create context menu
      await _updateContextMenu(isPerformanceMode: false);
    } catch (e) {
      debugPrint('Error initializing tray: $e');
    }
  }

  Future<void> _setIcon(String path) async {
    try {
      if (await File(path).exists()) {
        await trayManager.setIcon(path);
      } else {
        // Fallback to native Windows icon if asset is not found
        await trayManager.setIcon(_winIconPath);
      }
    } catch (_) {
      try {
        await trayManager.setIcon(_winIconPath);
      } catch (_) {}
    }
  }

  Future<void> updateTooltip(int percentage, String modeName, bool isCharging) async {
    if (!Platform.isWindows) return;
    try {
      final status = isCharging ? 'Charging' : 'Discharging';
      final tooltip = 'Battery: $percentage% ($status)\nMode: $modeName';
      await trayManager.setToolTip(tooltip);
    } catch (e) {
      debugPrint('Error setting tray tooltip: $e');
    }
  }

  Future<void> _updateContextMenu({required bool isPerformanceMode}) async {
    try {
      final menu = Menu(
        items: [
          MenuItem(
            key: 'open_dashboard',
            label: 'Open Dashboard',
          ),
          MenuItem.separator(),
          MenuItem.checkbox(
            key: 'enable_perf',
            label: 'Performance Mode Active',
            checked: isPerformanceMode,
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Exit',
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('Error updating tray menu: $e');
    }
  }

  void updateMenuState(bool isPerformanceMode) {
    if (!Platform.isWindows) return;
    _updateContextMenu(isPerformanceMode: isPerformanceMode);
  }

  // --- Flashing Tray Icon ---
  void startFlashing() {
    if (!Platform.isWindows || _isFlashing) return;
    _isFlashing = true;
    _isFlashOn = false;

    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      _isFlashOn = !_isFlashOn;
      if (_isFlashOn) {
        await _setIcon(_alertIconPath);
      } else {
        await _setIcon(_normalIconPath);
      }
    });
  }

  void stopFlashing() {
    if (!Platform.isWindows || !_isFlashing) return;
    _isFlashing = false;
    _flashTimer?.cancel();
    _flashTimer = null;
    _setIcon(_normalIconPath);
  }

  // --- TrayListener Event Handlers ---
  @override
  void onTrayIconMouseDown() {
    // Left-click restores the window
    _restoreWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    // trayManager displays the context menu automatically on Windows
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open_dashboard':
        _restoreWindow();
        _onOpenDashboard?.call();
        break;
      case 'enable_perf':
        // Toggle performance mode from tray
        final isChecked = menuItem.checked ?? false;
        if (isChecked) {
          _onDisablePerformanceMode?.call();
          _updateContextMenu(isPerformanceMode: false);
        } else {
          _onEnablePerformanceMode?.call();
          _updateContextMenu(isPerformanceMode: true);
        }
        break;
      case 'exit_app':
        _onExitApp?.call();
        break;
    }
  }

  void _restoreWindow() async {
    try {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      debugPrint('Error restoring window: $e');
    }
  }

  void destroy() {
    if (!Platform.isWindows) return;
    stopFlashing();
    trayManager.removeListener(this);
  }
}
