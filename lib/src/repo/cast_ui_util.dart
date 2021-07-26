import 'dart:async';
import 'dart:math';

import 'package:cast/cast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cast_ui/src/util/extensions/list_extensions.dart';
import 'package:cast_ui/src/util/extensions/cast/cast_device_extensions.dart';

class CastUiUtil {
  static CastUiUtil? _instance;

  late String _appId;
  String? _appSessionId;
  late BehaviorSubject<CastSession?> _activeSessionBS;
  late BehaviorSubject<int?> _activeMediaSessionIdBS;
  StreamSubscription<CastSessionState?>? _castSessionStateStream;
  StreamSubscription<Map<String, dynamic>?>? _messageStream;

  Stream<CastSession?> get activeSessionStream => _activeSessionBS.stream;

  Stream<bool> get hasActiveMediaSessionStream => _activeMediaSessionIdBS.stream.map((event) => event != null);

  Stream<bool> get hasActiveSessionStream => activeSessionStream.map((event) => event != null);

  CastUiUtil._();

  factory CastUiUtil() => _instance ??= CastUiUtil._();

  Future<void> init(String appId) async {
    _appId = appId;
    _activeSessionBS = BehaviorSubject<CastSession?>.seeded(null);
    _activeMediaSessionIdBS = BehaviorSubject<int?>.seeded(null);
  }

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
        _activeSessionBS.add(session);
        completer.complete(session);
      } else if (state == CastSessionState.connecting) {
        print('CONNECTING');
      } else if (state == CastSessionState.closed) {
        _activeSessionBS.add(null);
        _appSessionId = null;
      }
    });

    await _messageStream?.cancel();
    _messageStream = session.messageStream.listen((message) {
      print('receive message: $message');
      if (message.containsKey('type')) {
        if (message['type'] == 'RECEIVER_STATUS') {
          if (message.containsKey('status') && message['status'] is Map<String, dynamic>) {
            final status = message['status'] as Map<String, dynamic>;
            if (status.containsKey('applications') && status['applications'] is List<dynamic>) {
              final applications = status['applications'] as List<dynamic>;
              for (final application in applications) {
                if (application is Map<String, dynamic> && application.containsKey('appId') && application['appId'] == _appId) {
                  _appSessionId = application['sessionId'];
                  print('Found a new sessionId: $_appSessionId');
                }
              }
            }
          }
        }
        if (message['type'] == 'MEDIA_STATUS') {
          int? mediaSessionId;
          if (message.containsKey('status') && message['status'] is List<dynamic>) {
            final statuses = message['status'] as List<dynamic>;
            for (final status in statuses) {
              if (status is Map<String, dynamic> && status.containsKey('mediaSessionId') && status['idleReason'] != 'CANCELLED') {
                mediaSessionId = status['mediaSessionId'];
                print('Found a new _mediaSessionId: $mediaSessionId');
              }
            }
          }
          _activeMediaSessionIdBS.add(mediaSessionId);
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
    String? subtitleContentType = 'text/vtt',
  }) async {
    final session = await activeSessionStream.first;
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
      'tracks': [
        if (subtitleUrl != null)
          {
            'language': 'en-US',
            'name': 'English',
            'type': 'TEXT',
            'subtype': 'SUBTITLES',
            'trackId': 1,
            'trackContentId': subtitleUrl,
            'trackContentType': subtitleContentType,
          },
      ],
      'textTrackStyle': {
        'backgroundColor': '#00000000',
        'edgeType': 'OUTLINE',
        'edgeColor': '#000000FF',
        'fontScale': 1.1,
      }
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': currentTime,
      if (subtitleUrl != null)
        'activeTrackIds': [
          1,
        ],
      'media': message,
    });
  }

  Future<void> pauseStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSessionId = await _activeMediaSessionIdBS.first;
    if (mediaSessionId == null) return;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PAUSE',
      'requestId': Random().nextInt(974562),
      'mediaSessionId': mediaSessionId,
    });
  }

  Future<void> resumeStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSessionId = await _activeMediaSessionIdBS.first;
    if (mediaSessionId == null) return;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PLAY',
      'requestId': Random().nextInt(974562),
      'mediaSessionId': mediaSessionId,
    });
  }

  Future<void> stopStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSessionId = await _activeMediaSessionIdBS.first;
    if (mediaSessionId == null) return;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'STOP',
      'requestId': Random().nextInt(974562),
      'mediaSessionId': mediaSessionId,
    });
    _activeMediaSessionIdBS.add(null);
  }

  Future<void> seekStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSessionId = await _activeMediaSessionIdBS.first;
    if (mediaSessionId == null) return;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'Seek',
      'requestId': Random().nextInt(974562),
      'mediaSessionId': mediaSessionId,
    });
  }

  Future<void> stopSession() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'STOP',
      'sessionId': _appSessionId,
    });
    await stopStream();
    await Future.delayed(const Duration(seconds: 1));
    await CastSessionManager().endSession(session.sessionId);
    await _castSessionStateStream?.cancel();
    await _messageStream?.cancel();
    _activeSessionBS.add(null);
    _activeMediaSessionIdBS.add(null);
    _appSessionId = null;
  }
}
