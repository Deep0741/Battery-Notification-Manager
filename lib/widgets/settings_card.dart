import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/battery_mode.dart';
import '../core/theme.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isPerformance = settingsProvider.selectedMode == BatteryHealthMode.performance;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: FluentTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Start with Windows
          _buildSettingRow(
            context,
            icon: Icons.launch_rounded,
            title: 'Start with Windows',
            subtitle: 'Launch application minimized at system startup',
            control: Switch(
              value: settingsProvider.startWithWindows,
              onChanged: (val) => settingsProvider.setStartWithWindows(val),
            ),
          ),
          const Divider(height: 16),

          // Enable Sounds
          _buildSettingRow(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Enable Alerts Sounds',
            subtitle: 'Play chimes on notification and warning states',
            control: Switch(
              value: settingsProvider.enableSounds,
              onChanged: (val) => settingsProvider.setEnableSounds(val),
            ),
          ),
          const Divider(height: 16),

          // Enable Notifications
          _buildSettingRow(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Enable Toast Notifications',
            subtitle: 'Show Windows native notifications',
            control: Switch(
              value: settingsProvider.enableNotifications,
              onChanged: (val) => settingsProvider.setEnableNotifications(val),
            ),
          ),
          const Divider(height: 16),

          // Flash Tray Icon
          _buildSettingRow(
            context,
            icon: Icons.flourescent_rounded,
            title: 'Flash System Tray Icon',
            subtitle: 'Blink tray icon in red when warning is active',
            control: Switch(
              value: settingsProvider.flashTrayIcon,
              onChanged: (val) => settingsProvider.setFlashTrayIcon(val),
            ),
          ),
          const Divider(height: 16),

          // Warning Delay Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 20,
                        color: isPerformance ? Theme.of(context).disabledColor : FluentTheme.accentColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Warning Delay',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isPerformance ? Theme.of(context).disabledColor : null,
                            ),
                          ),
                          Text(
                            'Time to disconnect charger before repeating alerts',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: isPerformance ? Theme.of(context).disabledColor : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    isPerformance ? 'N/A' : '${settingsProvider.warningDelay} min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPerformance ? Theme.of(context).disabledColor : FluentTheme.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: settingsProvider.warningDelay.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: isPerformance ? Theme.of(context).disabledColor : FluentTheme.accentColor,
                inactiveColor: isPerformance
                    ? Theme.of(context).disabledColor.withOpacity(0.2)
                    : FluentTheme.accentColor.withOpacity(0.2),
                onChanged: isPerformance
                    ? null
                    : (val) => settingsProvider.setWarningDelay(val.toInt()),
              ),
            ],
          ),
          const Divider(height: 24),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () => settingsProvider.exitApplication(),
              icon: const Icon(Icons.power_settings_new_rounded, size: 18),
              label: const Text(
                'Exit Application',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget control,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: FluentTheme.accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        control,
      ],
    );
  }
}
