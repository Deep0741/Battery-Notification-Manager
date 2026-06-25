import 'dart:convert';

class LogEntry {
  final DateTime timestamp;
  final String message;
  final String type; // 'info', 'warning', 'success', 'system'

  LogEntry({
    required this.timestamp,
    required this.message,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'type': type,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      timestamp: DateTime.parse(map['timestamp'] as String),
      message: map['message'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LogEntry.fromJson(String source) =>
      LogEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
