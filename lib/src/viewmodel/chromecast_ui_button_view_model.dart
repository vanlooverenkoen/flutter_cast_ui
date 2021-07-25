import 'dart:async';

import 'package:cast_ui/src/repo/cast_ui_util.dart';
import 'package:cast_ui/src/util/dispose_mixin.dart';
import 'package:flutter/widgets.dart';

class ChromecastUiButtonViewModel extends ChangeNotifier with DisposeMixin {
  var _hasActiveSession = false;

  late final ChromecastUiButtonNavigator _navigator;

  StreamSubscription<bool>? _activeSessionSubscription;

  bool get hasActiveSession => _hasActiveSession;

  Future<void> init(ChromecastUiButtonNavigator navigator) async {
    _navigator = navigator;
    await _setupStreams();
  }

  @override
  void dispose() {
    _activeSessionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupStreams() async {
    await _activeSessionSubscription?.cancel();
    _activeSessionSubscription = CastUiUtil().hasActiveSession.listen((hasActiveSession) {
      if (disposed) return;
      _hasActiveSession = hasActiveSession;
      notifyListeners();
    });
  }

  Future<void> onClick() async {
    await _navigator.showChromecastDeviceDialog();
  }
}

// ignore: one_member_abstracts
abstract class ChromecastUiButtonNavigator {
  Future<void> showChromecastDeviceDialog();
}
