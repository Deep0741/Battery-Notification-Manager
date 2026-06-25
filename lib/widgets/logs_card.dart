import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../core/theme.dart';

class LogsCard extends StatelessWidget {
  const LogsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogProvider>();
    final logs = logProvider.logs;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16.0),
      decoration: FluentTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Event Logs (${logs.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (logs.isNotEmpty)
                TextButton.icon(
                  onPressed: () => logProvider.clearLogs(),
                  icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'No logs recorded yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark ? FluentTheme.darkBorder : FluentTheme.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final entry = logs[index];
                        
                        // Select indicator icon based on type
                        IconData icon;
                        Color color;
                        switch (entry.type) {
                          case 'success':
                            icon = Icons.check_circle_rounded;
                            color = FluentTheme.successColor;
                            break;
                          case 'warning':
                            icon = Icons.warning_rounded;
                            color = FluentTheme.warningColor;
                            break;
                          case 'info':
                            icon = Icons.info_outline;
                            color = FluentTheme.accentColor;
                            break;
                          case 'system':
                          default:
                            icon = Icons.settings_outlined;
                            color = isDark ? Colors.white60 : Colors.black54;
                            break;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? FluentTheme.darkBorder.withOpacity(0.5) : FluentTheme.lightBorder.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              Text(
                                _formatTime(entry.timestamp),
                                style: const TextStyle(
                                  fontFamily: 'Consolas',
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Icon
                              Icon(icon, size: 14, color: color),
                              const SizedBox(width: 8),
                              // Message
                              Expanded(
                                child: Text(
                                  entry.message,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Consolas',
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
    return '[$hour:$minute:$second]';
  }
}
