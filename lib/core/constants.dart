class AppConstants {
  // App Identifiers
  static const String appName = 'Battery Notification Manager';
  static const String appTitle = 'Battery Notification Manager';

  // Storage Keys
  static const String keySelectedMode = 'selected_mode';
  static const String keyStartWithWindows = 'start_with_windows';
  static const String keyEnableSounds = 'enable_sounds';
  static const String keyEnableNotifications = 'enable_notifications';
  static const String keyFlashTrayIcon = 'flash_tray_icon';
  static const String keyWarningDelay = 'warning_delay_minutes';
  static const String keyLogs = 'application_logs';

  // Default values
  static const int defaultWarningDelay = 5; // in minutes
  static const bool defaultStartWithWindows = false;
  static const bool defaultEnableSounds = true;
  static const bool defaultEnableNotifications = true;
  static const bool defaultFlashTrayIcon = true;

  // Notification configuration
  static const String notificationChannelId = 'battery_alerts';
  static const String notificationChannelName = 'Battery Alerts';
  static const String notificationChannelDesc = 'Alerts for battery status and charger disconnection warnings';
}
