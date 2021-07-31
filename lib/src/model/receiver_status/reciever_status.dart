import 'package:cast_ui/src/model/receiver_status/application.dart';

class ReceiverStatus {
  final List<Application> applications;

  const ReceiverStatus({
    required this.applications,
  });

  factory ReceiverStatus.fromJson(Map<String, dynamic> json) => ReceiverStatus(
        applications: (json['applications'] as List<dynamic>?)?.map((e) => Application.fromJson(e)).toList() ?? [],
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['applications'] = applications.map((e) => e.toJson()).toList();
    return data;
  }
}
