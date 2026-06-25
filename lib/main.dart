// BACKUP OF LIB/MAIN.DART
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme.dart';
import 'models/battery_mode.dart';
import 'providers/battery_provider.dart';
import 'providers/log_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/battery_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/startup_service.dart';
import 'services/storage_service.dart';
import 'services/tray_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Window Manager
  await windowManager.ensureInitialized();

  // Set window options
  const windowOptions = WindowOptions(
    size: Size(850, 680),
    minimumSize: Size(800, 620),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // Hides native bar to allow Fluent custom bar
  );

  // Prevent default window exit on clicking close (X)
  await windowManager.setPreventClose(true);

  // 2. Instantiate Services
  final storageService = StorageService();
  final startupService = StartupService();
  final soundService = SoundService();
  final notificationService = NotificationService();
  final trayService = TrayService();
  final batteryService = BatteryService();

  // 3. Initialize Services in Sequence
  await storageService.init();
  await startupService.init();
  await notificationService.init();

  // 4. Initialize Providers
  final settingsProvider = SettingsProvider(storageService, startupService, trayService);
  final logProvider = LogProvider(storageService);
  final batteryProvider = BatteryProvider(
    batteryService,
    notificationService,
    soundService,
    trayService,
    settingsProvider,
    logProvider,
  );

  // 5. Initialize System Tray
  await trayService.initTray(
    onOpenDashboard: () async {
      await windowManager.show();
      await windowManager.focus();
    },
    onEnablePerformanceMode: () {
      settingsProvider.setSelectedMode(BatteryHealthMode.performance);
    },
    onDisablePerformanceMode: () {
      settingsProvider.setSelectedMode(BatteryHealthMode.balanced);
    },
    onExitApp: () async {
      trayService.destroy();
      await windowManager.destroy();
    },
  );

  // Log application startup
  logProvider.addLog('Battery Notification Manager started.', 'system');

  // 6. Launch Window or Keep Hidden if Started Minimized
  final startMinimized = args.contains('--minimized') || args.contains('-m');
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (startMinimized) {
      // Start hidden in tray
      await windowManager.hide();
      logProvider.addLog('Application launched minimized to system tray.', 'system');
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: logProvider),
        ChangeNotifierProvider.value(value: batteryProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Notification Manager',
      debugShowCheckedModeBanner: false,
      theme: FluentTheme.lightTheme,
      darkTheme: FluentTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically follow Windows dark/light theme
      home: const DashboardScreen(),
    );
  }
}
