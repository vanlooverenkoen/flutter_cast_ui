import 'package:cast_ui/src/model/media_status/media.dart';

class MediaSessionStatus {
  final int mediaSessionId;
  final int playbackRate;
  final String playerState;
  final double currentTime;
  final int supportedMediaCommands;
  final int currentItemId;
  final Media? media;
  final String? repeatMode;
  final String? idleReason;

  const MediaSessionStatus({
    required this.mediaSessionId,
    required this.playbackRate,
    required this.playerState,
    required this.currentTime,
    required this.supportedMediaCommands,
    required this.currentItemId,
    required this.media,
    required this.repeatMode,
    required this.idleReason,
  });

  factory MediaSessionStatus.fromJson(Map<String, dynamic> json) {
    return MediaSessionStatus(
        mediaSessionId: json['mediaSessionId'] as int,
        playbackRate: json['playbackRate'] as int,
        playerState: json['playerState'] as String,
        currentTime: json['currentTime'] is int ? (json['currentTime'] as int).toDouble() : json['currentTime'] as double,
        supportedMediaCommands: json['supportedMediaCommands'] as int,
        currentItemId: json['currentItemId'] as int,
        media: json['media'] is Map<String, dynamic> ? Media.fromJson(json['media'] as Map<String, dynamic>) : null,
        repeatMode: json['repeatMode'] as String?,
        idleReason: json['idleReason'] as String?,
      );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mediaSessionId'] = mediaSessionId;
    data['playbackRate'] = playbackRate;
    data['playerState'] = playerState;
    data['currentTime'] = currentTime;
    data['supportedMediaCommands'] = supportedMediaCommands;
    data['currentItemId'] = currentItemId;
    data['repeatMode'] = repeatMode;
    data['idleReason'] = idleReason;
    return data;
  }

  bool get isActive => playerState != 'IDLE';

  bool get isPlaying => playerState == 'PLAYING';
}
