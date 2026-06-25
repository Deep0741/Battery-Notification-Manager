import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/battery_mode.dart';
import '../models/log_entry.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Mode ---
  BatteryHealthMode getSelectedMode() {
    final val = _prefs.getString(AppConstants.keySelectedMode);
    if (val == null) {
      return BatteryHealthMode.balanced; // Default mode
    }
    return BatteryHealthModeExtension.fromId(val);
  }

  Future<void> setSelectedMode(BatteryHealthMode mode) async {
    await _prefs.setString(AppConstants.keySelectedMode, mode.id);
  }

  // --- Start with Windows ---
  bool getStartWithWindows() {
    return _prefs.getBool(AppConstants.keyStartWithWindows) ?? AppConstants.defaultStartWithWindows;
  }

  Future<void> setStartWithWindows(bool value) async {
    await _prefs.setBool(AppConstants.keyStartWithWindows, value);
  }

  // --- Enable Sounds ---
  bool getEnableSounds() {
    return _prefs.getBool(AppConstants.keyEnableSounds) ?? AppConstants.defaultEnableSounds;
  }

  Future<void> setEnableSounds(bool value) async {
    await _prefs.setBool(AppConstants.keyEnableSounds, value);
  }

  // --- Enable Notifications ---
  bool getEnableNotifications() {
    return _prefs.getBool(AppConstants.keyEnableNotifications) ?? AppConstants.defaultEnableNotifications;
  }

  Future<void> setEnableNotifications(bool value) async {
    await _prefs.setBool(AppConstants.keyEnableNotifications, value);
  }

  // --- Flash Tray Icon ---
  bool getFlashTrayIcon() {
    return _prefs.getBool(AppConstants.keyFlashTrayIcon) ?? AppConstants.defaultFlashTrayIcon;
  }

  Future<void> setFlashTrayIcon(bool value) async {
    await _prefs.setBool(AppConstants.keyFlashTrayIcon, value);
  }

  // --- Warning Delay ---
  int getWarningDelay() {
    return _prefs.getInt(AppConstants.keyWarningDelay) ?? AppConstants.defaultWarningDelay;
  }

  Future<void> setWarningDelay(int minutes) async {
    await _prefs.setInt(AppConstants.keyWarningDelay, minutes);
  }

  // --- Event Logs ---
  List<LogEntry> getLogs() {
    final list = _prefs.getStringList(AppConstants.keyLogs);
    if (list == null) return [];
    try {
      return list.map((jsonStr) => LogEntry.fromJson(jsonStr)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLogs(List<LogEntry> logs) async {
    // Limit to 100 logs
    final trimmedLogs = logs.length > 100 ? logs.sublist(0, 100) : logs;
    final list = trimmedLogs.map((entry) => entry.toJson()).toList();
    await _prefs.setStringList(AppConstants.keyLogs, list);
  }

  Future<void> addLog(LogEntry entry) async {
    final logs = getLogs();
    logs.insert(0, entry);
    await saveLogs(logs);
  }
}
