
import 'dart:async';

import 'package:flutter/services.dart';

class CastUi {
  static const MethodChannel _channel =
      const MethodChannel('cast_ui');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
