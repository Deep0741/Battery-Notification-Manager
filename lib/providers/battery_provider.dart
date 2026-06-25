import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../models/battery_mode.dart';
import '../services/battery_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/tray_service.dart';
import 'settings_provider.dart';
import 'log_provider.dart';

class BatteryProvider with ChangeNotifier {
  final BatteryService _batteryService;
  final NotificationService _notificationService;
  final SoundService _soundService;
  final TrayService _trayService;
  final SettingsProvider _settingsProvider;
  final LogProvider _logProvider;

  // State Variables
  int _batteryLevel = 100;
  bool _isCharging = false;
  DateTime? _lastUpdated;
  
  bool _hasNotifiedThreshold = false;
  bool _isWarningActive = false;
  DateTime? _warningStartTime;
  Duration? _timeRemaining;

  Timer? _checkTimer;
  Timer? _uiTickTimer;
  Timer? _repeatWarningTimer;

  // Track previous states to avoid spamming logs
  bool? _prevChargingState;
  int? _prevBatteryLevel;

  BatteryProvider(
    this._batteryService,
    this._notificationService,
    this._soundService,
    this._trayService,
    this._settingsProvider,
    this._logProvider,
  ) {
    _init();
  }

  // Getters
  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isWarningActive => _isWarningActive;
  DateTime? get warningStartTime => _warningStartTime;
  Duration? get timeRemaining => _timeRemaining;

  // Initialize service
  Future<void> _init() async {
    // Initial check
    await checkBatteryStatus();

    // Listen to charger state changes via stream (immediate response)
    _batteryService.onBatteryStateChanged.listen((state) {
      checkBatteryStatus();
    });

    // Check battery every 30 seconds (periodic poll fallback)
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkBatteryStatus();
    });

    // Watch for mode/settings changes
    _settingsProvider.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (_warningStartTime != null && !_isWarningActive) {
      final delay = Duration(minutes: _settingsProvider.warningDelay);
      final elapsed = DateTime.now().difference(_warningStartTime!);
      final remaining = delay - elapsed;
      _timeRemaining = remaining.isNegative ? Duration.zero : remaining;
      
      if (_timeRemaining == Duration.zero) {
        _uiTickTimer?.cancel();
        _uiTickTimer = null;
        _triggerWarningAlert();
      }
    }
    // Re-check status if mode or settings change
    checkBatteryStatus();
  }

  /// Polls the battery and drives the warning logic.
  Future<void> checkBatteryStatus() async {
    final level = await _batteryService.getBatteryLevel();
    final charging = await _batteryService.getChargingStatus();

    _batteryLevel = level;
    _isCharging = charging;
    _lastUpdated = DateTime.now();

    final activeMode = _settingsProvider.selectedMode;

    // 1. Update Tooltip in System Tray
    _trayService.updateTooltip(_batteryLevel, activeMode.name, _isCharging);

    // 2. Log changes in battery level or charging status
    if (_prevChargingState != _isCharging) {
      final msg = _isCharging ? 'Charger connected.' : 'Charger disconnected.';
      _logProvider.addLog(msg, 'info');
      _prevChargingState = _isCharging;
    }
    if (_prevBatteryLevel != _batteryLevel) {
      if (_batteryLevel % 5 == 0 || _batteryLevel == activeMode.thresholdPercentage || _batteryLevel == 100) {
        _logProvider.addLog('Battery percentage: $_batteryLevel%', 'info');
      }
      _prevBatteryLevel = _batteryLevel;
    }

    // 3. Performance Mode Bypass
    if (activeMode == BatteryHealthMode.performance) {
      _resetAlerts(silent: true);
      notifyListeners();
      return;
    }

    final threshold = activeMode.thresholdPercentage;

    // 4. Charger is Disconnected - Reset Alerts
    if (!_isCharging) {
      _resetAlerts();
      notifyListeners();
      return;
    }

    // 5. Charger is Connected and Charging
    if (_batteryLevel >= threshold) {
      // Step A: Trigger First-Time Alert
      if (!_hasNotifiedThreshold) {
        _hasNotifiedThreshold = true;
        _logProvider.addLog('Battery reached threshold level ($threshold% in ${activeMode.name}).', 'success');

        if (_settingsProvider.enableNotifications) {
          _notificationService.showNotification(
            title: 'Battery Charged',
            body: 'Battery has reached $threshold%. Please disconnect the charger to preserve battery health.',
            onTap: _restoreAppWindow,
          );
        }
        if (_settingsProvider.enableSounds) {
          _soundService.playNotificationSound();
        }

        // Start Countdown Warning Timer
        _startWarningCountdown(_settingsProvider.warningDelay);
      }
    } else {
      // Charging but has dropped below the threshold percentage (e.g. heavy use)
      _resetAlerts(silent: true);
    }

    notifyListeners();
  }

  void _startWarningCountdown(int initialDelayMinutes) {
    _warningStartTime = DateTime.now();
    _timeRemaining = Duration(minutes: initialDelayMinutes);

    // Cancel existing UI ticker
    _uiTickTimer?.cancel();

    // Start 1-second ticker for UI countdown display
    _uiTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_warningStartTime == null) {
        timer.cancel();
        return;
      }

      final delay = Duration(minutes: _settingsProvider.warningDelay);
      final elapsed = DateTime.now().difference(_warningStartTime!);
      final remaining = delay - elapsed;

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        _timeRemaining = Duration.zero;
        timer.cancel();
        _triggerWarningAlert();
      } else {
        _timeRemaining = remaining;
      }
      notifyListeners();
    });

    _logProvider.addLog('Warning countdown started: $initialDelayMinutes minutes until alert.', 'info');
  }

  void _triggerWarningAlert() {
    if (_isWarningActive) return;
    _isWarningActive = true;
    _timeRemaining = Duration.zero;

    _logProvider.addLog('Warning triggered! Charger remains connected after full charge.', 'warning');

    _fireWarningEffects();

    // Start Repeating Warnings every 15 seconds
    _repeatWarningTimer?.cancel();
    _repeatWarningTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isCharging || _settingsProvider.selectedMode == BatteryHealthMode.performance) {
        timer.cancel();
        return;
      }
      _logProvider.addLog('Warning repeated: disconnect the charger.', 'warning');
      _fireWarningEffects();
    });
  }

  void _fireWarningEffects() {
    if (_settingsProvider.enableNotifications) {
      _notificationService.showNotification(
        title: 'Charging Warning',
        body: 'Charger is still connected after full charge. Continuous charging may reduce battery lifespan.',
        onTap: _restoreAppWindow,
      );
    }

    if (_settingsProvider.enableSounds) {
      _soundService.playWarningSound();
    }

    if (_settingsProvider.flashTrayIcon) {
      _trayService.startFlashing();
    }

    // Optional: Bring app to foreground on warning
    // We can restore the app window to focus attention
    _restoreAppWindow();
  }

  void _restoreAppWindow() async {
    try {
      if (await windowManager.isMinimized()) {
        await windowManager.restore();
      }
      await windowManager.show();
      await windowManager.focus();
    } catch (_) {}
  }

  void _resetAlerts({bool silent = false}) {
    // Log resetting of alerts
    if (!silent && (_isWarningActive || _warningStartTime != null)) {
      _logProvider.addLog('Resetting alarm state.', 'info');
    }

    _hasNotifiedThreshold = false;
    _isWarningActive = false;
    _warningStartTime = null;
    _timeRemaining = null;

    _uiTickTimer?.cancel();
    _uiTickTimer = null;

    _repeatWarningTimer?.cancel();
    _repeatWarningTimer = null;

    _trayService.stopFlashing();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _uiTickTimer?.cancel();
    _repeatWarningTimer?.cancel();
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }
}

// Extension to bridge helper for charging status check
extension on BatteryService {
  Future<bool> getChargingStatus() async {
    return await isCharging();
  }
}
