import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final _user32 = DynamicLibrary.open('user32.dll');
final _messageBeep = _user32.lookupFunction<Int32 Function(Uint32), int Function(int)>('MessageBeep');

class SoundService {
  /// Plays a standard Windows notification chime asynchronously.
  void playNotificationSound() {
    if (!Platform.isWindows) return;
    try {
      // Try playing modern Windows notification sound
      playSystemSound('Notification.Default');
    } catch (_) {
      try {
        _messageBeep(MB_ICONASTERISK);
      } catch (_) {}
    }
  }

  /// Plays a standard Windows warning chime asynchronously.
  void playWarningSound() {
    if (!Platform.isWindows) return;
    try {
      // Try playing standard Windows Exclamation chime
      playSystemSound('SystemExclamation');
    } catch (_) {
      try {
        _messageBeep(MB_ICONEXCLAMATION);
      } catch (_) {}
    }
  }

  /// Plays a specific system sound alias (e.g., 'SystemHand', 'Notification.Default')
  void playSystemSound(String soundAlias) {
    if (!Platform.isWindows) return;
    try {
      using((arena) {
        final soundName = soundAlias.toNativeUtf16(allocator: arena);
        PlaySound(
          soundName,
          NULL,
          SND_ALIAS | SND_ASYNC,
        );
      });
    } catch (_) {
      // Fallback
    }
  }
}
