import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/battery_mode.dart';
import '../providers/settings_provider.dart';
import '../core/theme.dart';

class ModeSelectorCard extends StatelessWidget {
  const ModeSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentMode = settingsProvider.selectedMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Battery Mode Selector',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: BatteryHealthMode.values.map((mode) {
            final isSelected = mode == currentMode;
            
            // Icon mapping
            IconData modeIcon;
            Color iconColor;
            switch (mode) {
              case BatteryHealthMode.batteryHealth:
                modeIcon = Icons.favorite_border_rounded;
                iconColor = Colors.green;
                break;
              case BatteryHealthMode.balanced:
                modeIcon = Icons.balance_rounded;
                iconColor = FluentTheme.accentColor;
                break;
              case BatteryHealthMode.performance:
                modeIcon = Icons.speed_rounded;
                iconColor = Colors.orange;
                break;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => settingsProvider.setSelectedMode(mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    height: 145,
                    decoration: FluentTheme.fluentCardDecoration(context, isSelected: isSelected),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              modeIcon,
                              color: iconColor,
                              size: 24,
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: FluentTheme.accentColor,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mode.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            mode.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
