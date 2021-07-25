import 'dart:async';

import 'package:cast/cast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cast_ui/src/util/extensions/list_extensions.dart';
import 'package:cast_ui/src/util/extensions/cast/cast_device_extensions.dart';

class CastUiUtil {
  static CastUiUtil? _instance;

  late String _appId;
  String? _appSessionId;
  late BehaviorSubject<CastSession?> _behaviorSubject;
  StreamSubscription<CastSessionState?>? _castSessionStateStream;
  StreamSubscription<Map<String, dynamic>?>? _messageStream;

  CastUiUtil._();

  factory CastUiUtil() => _instance ??= CastUiUtil._();

  Future<void> init(String appId) async {
    _appId = appId;
    _behaviorSubject = BehaviorSubject<CastSession?>.seeded(null);
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
      if (state == CastSessionState.connected) {
        if (completer.isCompleted) return;
        _behaviorSubject.add(session);
        completer.complete(session);
      } else if (state == CastSessionState.connecting) {
        print('CONNECTING');
      } else if (state == CastSessionState.closed) {
        _behaviorSubject.add(null);
        _appSessionId = null;
      }
    });

    await _messageStream?.cancel();
    _messageStream = session.messageStream.listen((message) {
      print('receive message: $message');
      if (message.containsKey('type') && message['type'] == 'RECEIVER_STATUS') {
        if (message.containsKey('status') && message['status'] is Map<String, dynamic>) {
          final status = message['status'] as Map<String, dynamic>;
          if (status.containsKey('applications') && status['applications'] is List<dynamic>) {
            final applications = status['applications'] as List<dynamic>;
            for (final application in applications) {
              if (application is Map<String, dynamic> && application.containsKey('appId') && application['appId'] == _appId) {
                _appSessionId =application['sessionId'];
                print('Found a new sessionId: ${_appSessionId}');
              }
            }
          }
        }
      }
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': _appId,
    });
    return completer.future;
  }

  Future<void> startPlayingStream({
    required String url,
    required String title,
    required String posterUrl,
    double currentTime = 0,
    String? subtitleUrl,
  }) async {
    final session = await activeSession.first;
    if (session == null) return;
    final message = {
      'contentId': url,
      'contentType': 'video/mp4',
      'streamType': 'BUFFERED',
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': title,
        'images': [
          {
            'url': posterUrl,
          }
        ],
      },
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': currentTime,
      'media': message,
    });
  }

  Future<void> stopSession() async {
    final session = await activeSession.first;
    if (session == null) return;
    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'STOP',
      'sessionId': _appSessionId,
    });
    await CastSessionManager().endSession(session.sessionId);
    await _castSessionStateStream?.cancel();
    await _messageStream?.cancel();
    _behaviorSubject.add(null);
    _appSessionId = null;
  }
}
