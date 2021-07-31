import 'package:cast_ui/src/model/media_status/media_meta_data.dart';

class Media {
  final MediaMetaData metadata;
  final double? duration;

  const Media({
    required this.metadata,
    required this.duration,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        metadata: MediaMetaData.fromJson(json['metadata'] as Map<String, dynamic>),
        duration: json.containsKey('duration')
            ? json['duration'] is int
                ? (json['duration'] as int).toDouble()
                : json['duration'] as double
            : null,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['metadata'] = metadata;
    data['duration'] = duration;
    return data;
  }
}
