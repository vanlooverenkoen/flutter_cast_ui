
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCastUi {
  static const MethodChannel _channel = MethodChannel('flutter_cast_ui');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
