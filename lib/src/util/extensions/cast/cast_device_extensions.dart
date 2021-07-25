import 'package:cast/cast.dart';

extension CastDeviceExtensions on CastDevice {
  String get friendlyName => extras['fn'] ?? '';

  String get deviceName => extras['md'] ?? '';
}
