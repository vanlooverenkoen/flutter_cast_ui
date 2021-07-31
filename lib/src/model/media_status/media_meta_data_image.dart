class MediaMetaDataImage {
  final String url;

  const MediaMetaDataImage({
    required this.url,
  });

  factory MediaMetaDataImage.fromJson(Map<String, dynamic> json) => MediaMetaDataImage(
    url: json['url'] as String,
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
