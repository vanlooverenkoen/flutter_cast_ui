import 'dart:async';

import 'package:flutter/services.dart';

class CastUi {
  static const _channel = MethodChannel('cast_ui');

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
