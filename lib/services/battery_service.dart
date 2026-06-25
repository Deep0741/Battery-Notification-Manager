import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  /// Gets the current battery percentage (0-100)
  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return 100; // Safe default
    }
  }

  /// Check if the charger is connected and battery is charging
  Future<bool> isCharging() async {
    try {
      final state = await _battery.batteryState;
      return state == BatteryState.charging || state == BatteryState.full;
    } catch (_) {
      return false;
    }
  }

  /// Listen to changes in the battery state
  Stream<BatteryState> get onBatteryStateChanged => _battery.onBatteryStateChanged;
}
