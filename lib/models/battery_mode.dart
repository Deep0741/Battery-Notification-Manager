enum BatteryHealthMode {
  batteryHealth, // Target 80%, 5 mins warning
  balanced,      // Target 90%, 10 mins warning
  performance,   // No alerts, continuous charging
}

extension BatteryHealthModeExtension on BatteryHealthMode {
  String get name {
    switch (this) {
      case BatteryHealthMode.batteryHealth:
        return 'Battery Health Mode';
      case BatteryHealthMode.balanced:
        return 'Balanced Mode';
      case BatteryHealthMode.performance:
        return 'Performance Mode';
    }
  }

  String get id {
    switch (this) {
      case BatteryHealthMode.batteryHealth:
        return 'health';
      case BatteryHealthMode.balanced:
        return 'balanced';
      case BatteryHealthMode.performance:
        return 'performance';
    }
  }

  String get description {
    switch (this) {
      case BatteryHealthMode.batteryHealth:
        return 'Notifies at 80% to protect long-term battery lifespan. Warning triggers after 5 minutes.';
      case BatteryHealthMode.balanced:
        return 'Notifies at 90% for a balance between capacity and lifespan. Warning triggers after 5 minutes.';
      case BatteryHealthMode.performance:
        return 'Disables alerts and limits. Optimized for plugged-in desktop usage and heavier workloads.';
    }
  }

  int get thresholdPercentage {
    switch (this) {
      case BatteryHealthMode.batteryHealth:
        return 80;
      case BatteryHealthMode.balanced:
        return 90;
      case BatteryHealthMode.performance:
        return 100;
    }
  }

  int get warningDelayMinutes {
    switch (this) {
      case BatteryHealthMode.batteryHealth:
        return 5;
      case BatteryHealthMode.balanced:
        return 5;
      case BatteryHealthMode.performance:
        return 0; // No warning
    }
  }

  static BatteryHealthMode fromId(String id) {
    switch (id) {
      case 'health':
        return BatteryHealthMode.batteryHealth;
      case 'balanced':
        return BatteryHealthMode.balanced;
      case 'performance':
      default:
        return BatteryHealthMode.performance;
    }
  }
}
