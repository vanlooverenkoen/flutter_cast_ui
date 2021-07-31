import 'package:cast_ui/src/model/media_status/media_meta_data_image.dart';

class MediaMetaData {
  final String? title;
  final List<MediaMetaDataImage> images;

  const MediaMetaData({
    required this.title,
    required this.images,
  });

  factory MediaMetaData.fromJson(Map<String, dynamic> json) {
    return MediaMetaData(
      title: json['title'] as String?,
      images: (json['images'] as List<dynamic>).map((e) => MediaMetaDataImage.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['images'] = images;
    return data;
  }
}
