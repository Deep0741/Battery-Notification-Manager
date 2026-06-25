import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/battery_provider.dart';
import '../providers/settings_provider.dart';
import '../models/battery_mode.dart';
import '../core/theme.dart';

class BatteryStatusCard extends StatelessWidget {
  const BatteryStatusCard({super.key});

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final batteryProvider = context.watch<BatteryProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final percentage = batteryProvider.batteryLevel;
    final isCharging = batteryProvider.isCharging;
    final lastUpdated = batteryProvider.lastUpdated;
    final mode = settingsProvider.selectedMode;
    final isWarningActive = batteryProvider.isWarningActive;
    final timeRemaining = batteryProvider.timeRemaining;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose battery color based on level
    Color batteryColor;
    if (percentage > 80) {
      batteryColor = FluentTheme.successColor;
    } else if (percentage > 25) {
      batteryColor = FluentTheme.accentColor;
    } else {
      batteryColor = FluentTheme.warningColor;
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: FluentTheme.cardDecoration(context),
      child: Row(
        children: [
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: isDark ? FluentTheme.darkBorder : FluentTheme.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                ),
              ),
              // Inner Details
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$percentage',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isCharging)
                    const Icon(
                      Icons.flash_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Battery status details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      isCharging ? 'Charging (AC Power)' : 'Discharging',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: isCharging ? FluentTheme.accentColor : null,
                      ),
                    ),
                    if (isCharging) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: FluentTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Active Mode: ${mode.name}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (lastUpdated != null)
                  Text(
                    'Last Updated: ${_formatTime(lastUpdated)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 8),
                // Warning / Timer section
                if (mode != BatteryHealthMode.performance && isCharging && percentage >= mode.thresholdPercentage)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWarningActive
                          ? FluentTheme.warningColor.withOpacity(0.1)
                          : FluentTheme.accentColor.withOpacity(0.08),
                      border: Border.all(
                        color: isWarningActive ? FluentTheme.warningColor : FluentTheme.accentColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWarningActive ? Icons.warning_amber_rounded : Icons.timer_outlined,
                          color: isWarningActive ? FluentTheme.warningColor : FluentTheme.accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isWarningActive
                              ? 'Disconnect charger warning active!'
                              : 'Warning countdown: ${_formatDuration(timeRemaining)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isWarningActive ? FluentTheme.warningColor : FluentTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (mode == BatteryHealthMode.performance)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FluentTheme.successColor.withOpacity(0.1),
                      border: Border.all(color: FluentTheme.successColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, color: FluentTheme.successColor, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Performance Mode Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FluentTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
