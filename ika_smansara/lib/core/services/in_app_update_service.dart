import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class InAppUpdateService {
  static const MethodChannel _channel =
      MethodChannel('com.ikasmansara/in_app_update');

  /// Trigger checks and prompt the user for an update if available
  static Future<void> checkForUpdate() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    
    try {
      final bool updateStarted = await _channel.invokeMethod('checkForUpdate');
      if (updateStarted) {
        debugPrint('In-app update prompt has been triggered.');
      } else {
        debugPrint('No update available or conditions not met.');
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to check for update: ${e.message}');
    }
  }
}
