import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../models/battery_mode.dart';
import '../services/storage_service.dart';
import '../services/startup_service.dart';
import '../services/tray_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;
  final StartupService _startupService;
  final TrayService _trayService;

  late BatteryHealthMode _selectedMode;
  late bool _startWithWindows;
  late bool _enableSounds;
  late bool _enableNotifications;
  late bool _flashTrayIcon;
  late int _warningDelay;

  SettingsProvider(this._storageService, this._startupService, this._trayService) {
    _loadSettings();
  }

  // Getters
  BatteryHealthMode get selectedMode => _selectedMode;
  bool get startWithWindows => _startWithWindows;
  bool get enableSounds => _enableSounds;
  bool get enableNotifications => _enableNotifications;
  bool get flashTrayIcon => _flashTrayIcon;
  int get warningDelay => _warningDelay;

  // Setters & Actions
  void _loadSettings() {
    _selectedMode = _storageService.getSelectedMode();
    _startWithWindows = _storageService.getStartWithWindows();
    _enableSounds = _storageService.getEnableSounds();
    _enableNotifications = _storageService.getEnableNotifications();
    _flashTrayIcon = _storageService.getFlashTrayIcon();
    _warningDelay = _storageService.getWarningDelay();
    
    // Sync the tray menu state
    _trayService.updateMenuState(_selectedMode == BatteryHealthMode.performance);
  }

  Future<void> setSelectedMode(BatteryHealthMode mode) async {
    _selectedMode = mode;
    await _storageService.setSelectedMode(mode);
    
    // Sync context menu checkbox
    _trayService.updateMenuState(mode == BatteryHealthMode.performance);
    
    notifyListeners();
  }

  Future<void> setStartWithWindows(bool value) async {
    _startWithWindows = value;
    await _storageService.setStartWithWindows(value);
    await _startupService.setLaunchAtStartup(value);
    notifyListeners();
  }

  Future<void> setEnableSounds(bool value) async {
    _enableSounds = value;
    await _storageService.setEnableSounds(value);
    notifyListeners();
  }

  Future<void> setEnableNotifications(bool value) async {
    _enableNotifications = value;
    await _storageService.setEnableNotifications(value);
    notifyListeners();
  }

  Future<void> setFlashTrayIcon(bool value) async {
    _flashTrayIcon = value;
    await _storageService.setFlashTrayIcon(value);
    notifyListeners();
  }

  Future<void> setWarningDelay(int minutes) async {
    _warningDelay = minutes;
    await _storageService.setWarningDelay(minutes);
    notifyListeners();
  }

  Future<void> exitApplication() async {
    _trayService.destroy();
    await windowManager.destroy();
  }
}
