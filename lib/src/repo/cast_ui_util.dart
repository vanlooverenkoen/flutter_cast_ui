import 'dart:async';

import 'package:cast/cast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cast_ui/src/util/extensions/list_extensions.dart';
import 'package:cast_ui/src/util/extensions/cast/cast_device_extensions.dart';

class CastUiUtil {
  static CastUiUtil? _instance;

  late String _appId;
  late BehaviorSubject<CastSession?> _behaviorSubject;
  StreamSubscription<CastSessionState?>? _castSessionStateStream;
  StreamSubscription<Map<String, dynamic>?>? _messageStream;

  CastUiUtil._();

  factory CastUiUtil() => _instance ??= CastUiUtil._();

  Future<void> init(String appId) async {
    _appId = appId;
    _behaviorSubject = BehaviorSubject<CastSession?>();
  }

  Stream<CastSession?> get activeSession => _behaviorSubject.stream;

  Stream<bool> get hasActiveSession => activeSession.map((event) => event != null);

  Future<List<CastDevice>> getCastDevices({Duration timeout = const Duration(seconds: 5)}) async {
    final result = await CastDiscoveryService().search(timeout: timeout);
    result.sortBy((item) => item.friendlyName.toLowerCase());
    return result;
  }

  Future<CastSession> startSession(CastDevice device) async {
    final completer = Completer<CastSession>();
    final session = await CastSessionManager().startSession(device);
    await _castSessionStateStream?.cancel();
    _castSessionStateStream = session.stateStream.listen((state) {
      print(state);
      if (state == CastSessionState.connected) {
        if (completer.isCompleted) return;
        _behaviorSubject.add(session);
        completer.complete(session);
      } else if (state == CastSessionState.connecting) {
        print('CONNECTING');
      } else if (state == CastSessionState.closed) {
        _behaviorSubject.add(null);
      }
    });

    await _messageStream?.cancel();
    _messageStream = session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': _appId,
    });
    return completer.future;
  }

  Future<void> stopSession() async {
    final session = await activeSession.first;
    if (session == null) return;
    await CastSessionManager().endSession(session.sessionId);
    await _castSessionStateStream?.cancel();
    await _messageStream?.cancel();
    _behaviorSubject.add(null);
  }
}
