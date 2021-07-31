class Application {
  final String appId;
  final String appType;
  final String displayName;
  final bool isIdleScreen;
  final bool launchedFromCloud;
  final String sessionId;
  final String statusText;
  final String transportId;
  final String universalAppId;

  Application({
    required this.appId,
    required this.appType,
    required this.displayName,
    required this.isIdleScreen,
    required this.launchedFromCloud,
    required this.sessionId,
    required this.statusText,
    required this.transportId,
    required this.universalAppId,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        appId: json['appId'] as String,
        appType: json['appType'] as String,
        displayName: json['displayName'] as String,
        isIdleScreen: json['isIdleScreen'] as bool,
        launchedFromCloud: json['launchedFromCloud'] as bool,
        sessionId: json['sessionId'] as String,
        statusText: json['statusText'] as String,
        transportId: json['transportId'] as String,
        universalAppId: json['universalAppId'] as String,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['appId'] = appId;
    data['appType'] = appType;
    data['displayName'] = displayName;
    data['isIdleScreen'] = isIdleScreen;
    data['launchedFromCloud'] = launchedFromCloud;
    data['sessionId'] = sessionId;
    data['statusText'] = statusText;
    data['transportId'] = transportId;
    data['universalAppId'] = universalAppId;
    return data;
  }
}
