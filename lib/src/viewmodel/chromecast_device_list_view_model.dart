import 'package:cast/cast.dart';
import 'package:cast_ui/src/util/dispose_mixin.dart';
import 'package:flutter/widgets.dart';

class ChromecastDeviceListViewModel extends ChangeNotifier with DisposeMixin {
  late final ChromecastDeviceListNavigator _navigator;

  var _isConnected = false;
  var _isLoading = false;
  var _hasError = false;
  final _data = <CastDevice>[];

  bool get isConnected => _isConnected;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  bool get hasData => _data.isNotEmpty;

  bool get hasNoData => _data.isEmpty;

  List<CastDevice> get data => _data;

  Future<void> init(ChromecastDeviceListNavigator navigator) async {
    _navigator = navigator;
    await _getData();
  }

  Future<void> _getData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      final result = await CastDiscoveryService().search();
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
    final session = await CastSessionManager().startSession(device);
    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        _isConnected = true;
        _isLoading = false;
        notifyListeners();
      }
    });

    session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'B6DF242C', // set the appId of your app here
    });
  }
}

// ignore: one_member_abstracts
abstract class ChromecastDeviceListNavigator {
  void goBack();
}
