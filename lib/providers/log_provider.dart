import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';

class LogProvider with ChangeNotifier {
  final StorageService _storageService;
  List<LogEntry> _logs = [];

  LogProvider(this._storageService) {
    _loadLogs();
  }

  List<LogEntry> get logs => _logs;

  void _loadLogs() {
    _logs = _storageService.getLogs();
    notifyListeners();
  }

  Future<void> addLog(String message, String type) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      message: message,
      type: type,
    );
    _logs.insert(0, entry);
    if (_logs.length > 100) {
      _logs = _logs.sublist(0, 100);
    }
    await _storageService.saveLogs(_logs);
    notifyListeners();
  }

  Future<void> clearLogs() async {
    _logs.clear();
    await _storageService.saveLogs(_logs);
    notifyListeners();
  }
}
