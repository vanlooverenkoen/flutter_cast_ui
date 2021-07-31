import 'dart:async';
import 'package:cast/cast.dart';
import 'package:cast_ui/src/model/media_status/media.dart';
import 'package:cast_ui/src/model/media_status/media_status.dart';
import 'package:cast_ui/src/model/receiver_status/reciever_status.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cast_ui/src/util/extensions/list_extensions.dart';
import 'package:cast_ui/src/util/extensions/cast/cast_device_extensions.dart';

class CastUiUtil {
  static CastUiUtil? _instance;

  late String _appId;
  String? _appSessionId;
  late BehaviorSubject<CastSession?> _activeSessionBS;
  Media? _lastActiveMedia;
  double? _lastActiveMediaDuration;
  late BehaviorSubject<MediaSessionStatus?> _activeMediaSessionIdBS;
  StreamSubscription<CastSessionState?>? _castSessionStateStream;
  StreamSubscription<Map<String, dynamic>?>? _messageStream;

  Stream<CastSession?> get activeSessionStream => _activeSessionBS.stream;

  Stream<bool> get hasActiveMediaSessionStream => activeMediaSessionStream.map((event) => event != null && event.isActive);

  Stream<MediaSessionStatus?> get activeMediaSessionStream => _activeMediaSessionIdBS.stream;

  Stream<bool> get hasActiveSessionStream => activeSessionStream.map((event) => event != null);

  Media? get lastActiveMedia => _lastActiveMedia;

  double? get lastActiveMediaDuration => _lastActiveMediaDuration;

  CastUiUtil._();

  factory CastUiUtil() => _instance ??= CastUiUtil._();

  Future<void> init(String appId) async {
    _appId = appId;
    _activeSessionBS = BehaviorSubject<CastSession?>.seeded(null);
    _activeMediaSessionIdBS = BehaviorSubject<MediaSessionStatus?>.seeded(null);
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
        _lastActiveMedia = null;
        _lastActiveMediaDuration = null;
      }
    });

    await _messageStream?.cancel();
    _messageStream = session.messageStream.listen((message) {
      print('receive message: $message');
      if (!message.containsKey('type')) return;
      if (message['type'] == 'RECEIVER_STATUS') {
        final receiverStatus = ReceiverStatus.fromJson(message['status'] as Map<String, dynamic>);
        for (final application in receiverStatus.applications) {
          if (application is Map<String, dynamic> && application.appId == _appId) {
            _appSessionId = application.sessionId;
            print('Found a new sessionId: $_appSessionId');
          }
        }
      }
      if (message['type'] == 'MEDIA_STATUS') {
        MediaSessionStatus? mediaStatus;
        if (message.containsKey('status') && message['status'] is List<dynamic>) {
          final statuses = message['status'] as List<dynamic>;
          final mediaStatuses = statuses.map((e) => MediaSessionStatus.fromJson(e as Map<String, dynamic>)).toList();
          mediaStatus = mediaStatuses.isEmpty ? null : mediaStatuses.first;
        }
        if (mediaStatus?.media != null) {
          _lastActiveMedia = mediaStatus?.media;
          if (mediaStatus?.media?.duration != null) {
            _lastActiveMediaDuration = mediaStatus?.media?.duration;
          }
        }
        _activeMediaSessionIdBS.add(mediaStatus);
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
    String? subtitleContentType,
  }) async {
    _lastActiveMedia = null;
    _lastActiveMediaDuration = null;
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
    final mediaSession = await _activeMediaSessionIdBS.first;
    if (mediaSession == null) return;
    final mediaSessionId = mediaSession.mediaSessionId;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PAUSE',
      'mediaSessionId': mediaSessionId,
    });
  }

  Future<void> resumeStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSession = await _activeMediaSessionIdBS.first;
    if (mediaSession == null) return;
    final mediaSessionId = mediaSession.mediaSessionId;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'PLAY',
      'mediaSessionId': mediaSessionId,
    });
  }

  Future<void> stopStream() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSession = await _activeMediaSessionIdBS.first;
    if (mediaSession == null) return;
    final mediaSessionId = mediaSession.mediaSessionId;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'STOP',
      'mediaSessionId': mediaSessionId,
    });
    _activeMediaSessionIdBS.add(null);
  }

  Future<void> seekStream(double currentTime) async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSession = await activeMediaSessionStream.first;
    if (mediaSession == null) return;
    var actualTime = currentTime;
    if (actualTime > (_lastActiveMediaDuration ?? 0)) {
      actualTime = _lastActiveMediaDuration ?? 0;
    } else if (actualTime < 0) {
      actualTime = 0;
    }
    final mediaSessionId = mediaSession.mediaSessionId;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'SEEK',
      'mediaSessionId': mediaSessionId,
      'currentTime': currentTime,
    });
  }

  Future<void> scrubStreamBackwards({Duration duration = const Duration(seconds: 10)}) async {
    final mediaSession = await activeMediaSessionStream.first;
    if (mediaSession == null) return;
    await seekStream(mediaSession.currentTime - duration.inSeconds);
  }

  Future<void> scrubStreamForward({Duration duration = const Duration(seconds: 10)}) async {
    final mediaSession = await activeMediaSessionStream.first;
    if (mediaSession == null) return;
    await seekStream(mediaSession.currentTime + duration.inSeconds);
  }

  Future<void> getStatus() async {
    final session = await activeSessionStream.first;
    if (session == null) return;
    final mediaSession = await _activeMediaSessionIdBS.first;
    if (mediaSession == null) return;
    final mediaSessionId = mediaSession.mediaSessionId;
    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'GET_STATUS',
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
    _lastActiveMedia = null;
    _lastActiveMediaDuration = null;
  }
}
