import 'package:cast_ui/src/util/dispose_mixin.dart';
import 'package:flutter/widgets.dart';

class ChromecastUiButtonViewModel extends ChangeNotifier with DisposeMixin {
  var _isConnected = false;

  late final ChromecastUiButtonNavigator _navigator;

  bool get isConnected => _isConnected;

  Future<void> init(ChromecastUiButtonNavigator navigator) async {
    _navigator = navigator;
    _setupStreams();
  }

  void _setupStreams() {}

  Future<void> onClick() async {
    await _navigator.showChromecastDeviceDialog();
    if (disposed) return;
    _isConnected = !_isConnected;
    notifyListeners();
  }
}

// ignore: one_member_abstracts
abstract class ChromecastUiButtonNavigator {
  Future<void> showChromecastDeviceDialog();
}
