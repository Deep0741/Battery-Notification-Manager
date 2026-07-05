import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

final _user32 = DynamicLibrary.open('user32.dll');
final _messageBeep = _user32.lookupFunction<Int32 Function(Uint32), int Function(int)>('MessageBeep');

class SoundService {
  /// Plays a standard Windows notification chime asynchronously.
  void playNotificationSound() {
    _play([
      r'C:\Windows\Media\Windows Background.wav',
      r'C:\Windows\Media\notify.wav',
      'Notification.Default',
      'SystemAsterisk'
    ], MB_ICONASTERISK);
  }

  /// Plays a standard Windows warning chime asynchronously.
  void playWarningSound() {
    _play([
      r'C:\Windows\Media\Windows Exclamation.wav',
      r'C:\Windows\Media\chimes.wav',
      r'C:\Windows\Media\chord.wav',
      'SystemExclamation',
      'SystemHand'
    ], MB_ICONEXCLAMATION);
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

  /// Plays a list of sound options (files/aliases) in order, falling back to MessageBeep if all fail.
  void _play(List<String> options, int uTypeFallback) {
    if (!Platform.isWindows) return;
    try {
      using((arena) {
        for (final option in options) {
          final isFile = option.endsWith('.wav');
          final flag = isFile ? SND_FILENAME : SND_ALIAS;
          final result = PlaySound(
            option.toNativeUtf16(allocator: arena),
            NULL,
            flag | SND_ASYNC | SND_NODEFAULT,
          );
          if (result != 0) {
            return; // Successfully played
          }
        }
        // If PlaySound failed for all options, use MessageBeep as ultimate fallback
        _messageBeep(uTypeFallback);
      });
    } catch (_) {
      try {
        _messageBeep(uTypeFallback);
      } catch (_) {}
    }
  }
}
