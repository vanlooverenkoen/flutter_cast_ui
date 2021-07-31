import 'package:cast_ui/src/model/media_status/media_meta_data.dart';

class Media {
  final MediaMetaData metadata;

  const Media({
    required this.metadata,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
      metadata: MediaMetaData.fromJson(json['metadata'] as Map<String, dynamic>),
    );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['metadata'] = metadata;
    return data;
  }
}
