import 'dart:async';

import 'package:cast/cast.dart';
import 'package:rxdart/rxdart.dart';

class CastUiUtil {
  static CastUiUtil? _instance;

  late String _appId;
  late BehaviorSubject<CastSession?> _behaviorSubject;

  CastUiUtil._();

  factory CastUiUtil() => _instance ??= CastUiUtil._();

  Future<void> init(String appId) async {
    _appId = appId;
    _behaviorSubject = BehaviorSubject<CastSession>();
  }

  Stream<CastSession?> get activeSession => _behaviorSubject.stream;

  Stream<bool> get hasActiveSession => activeSession.map((event) => event != null);

  Future<List<CastDevice>> getCastDevices({Duration timeout = const Duration(seconds: 5)}) => CastDiscoveryService().search(timeout: timeout);

  Future<CastSession> startSession(CastDevice device) async {
    final completer = Completer<CastSession>();
    final session = await CastSessionManager().startSession(device);
    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        if (completer.isCompleted) return;
        completer.complete(session);
      } else if (state == CastSessionState.connecting) {
        //todo loading
      } else if (state == CastSessionState.closed) {
        //todo closed
      }
    });

    session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': _appId,
    });
    return completer.future;
  }
}
