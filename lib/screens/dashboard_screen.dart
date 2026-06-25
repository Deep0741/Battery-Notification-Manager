import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/mode_selector_card.dart';
import '../widgets/settings_card.dart';
import '../widgets/logs_card.dart';
import '../providers/battery_provider.dart';
import '../core/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Overriding close to minimize to tray instead
    final isMinimizedToTray = await windowManager.isPreventClose();
    if (isMinimizedToTray) {
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final batteryProvider = context.watch<BatteryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF18181F), const Color(0xFF22242D)]
                : [const Color(0xFFF3F3F7), const Color(0xFFEBEBF2)],
          ),
        ),
        child: Column(
          children: [
            // Custom Fluent-style Window Header / Title Bar
            DragToMoveArea(
              child: Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? FluentTheme.darkBorder : FluentTheme.lightBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.battery_saver_rounded,
                      color: FluentTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battery Notification Manager',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Native Window control replicas or space padding
                    // Minimizes / Closes are handled by standard window buttons,
                    // but we can provide custom window controls here if we hide standard ones.
                    // Since we use standard window border, this space is just for dragging.
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          tooltip: 'Minimize',
                          onPressed: () => windowManager.minimize(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          tooltip: 'Close to Tray',
                          onPressed: () => windowManager.hide(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Battery Status Card
                    const BatteryStatusCard(),
                    const SizedBox(height: 20),

                    // Battery Health Mode Cards
                    const ModeSelectorCard(),
                    const SizedBox(height: 20),

                    // Settings and Logs Side-By-Side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Settings Card (Left)
                        const Expanded(
                          child: SettingsCard(),
                        ),
                        const SizedBox(width: 16),
                        // Logs Card (Right)
                        const Expanded(
                          child: LogsCard(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
