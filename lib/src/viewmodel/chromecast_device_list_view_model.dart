import 'dart:async';

import 'package:cast/device.dart';
import 'package:cast/session.dart';
import 'package:cast_ui/cast_ui.dart';
import 'package:cast_ui/src/util/dispose_mixin.dart';
import 'package:flutter/widgets.dart';

class ChromecastDeviceListViewModel extends ChangeNotifier with DisposeMixin {
  late final ChromecastDeviceListNavigator _navigator;

  CastSession? _activeSession;
  var _isLoading = false;
  var _hasError = false;
  final _data = <CastDevice>[];

  StreamSubscription<CastSession?>? _activeSessionSubscription;

  bool get isConnected => _activeSession != null;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  bool get hasData => _data.isNotEmpty;

  bool get hasNoData => _data.isEmpty;

  List<CastDevice> get data => _data;

  Future<void> init(ChromecastDeviceListNavigator navigator) async {
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
    _activeSessionSubscription = CastUiUtil().activeSessionStream.listen((session) {
      if (disposed) return;
      _activeSession = session;
      notifyListeners();
      if (_activeSession == null) {
        _getData();
      }
    });
  }

  Future<void> _getData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await CastUiUtil().getCastDevices();
      _data
        ..clear()
        ..addAll(result);
    } catch (e) {
      _hasError = true;
      print('Failed to get the latest chromecast devices');
    }
    if (disposed) return;
    _isLoading = false;
    notifyListeners();
  }

  void onRetryClicked() => _getData();

  void onDeviceClicked(CastDevice device) {
    _connectToYourApp(device);
  }

  Future<void> _connectToYourApp(CastDevice device) async {
    _isLoading = true;
    notifyListeners();
    await CastUiUtil().startSession(device);
    _isLoading = false;
    notifyListeners();
  }
}

// ignore: one_member_abstracts
abstract class ChromecastDeviceListNavigator {
  void goBack();
}
