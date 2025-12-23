class NotificationModel {
  final int id;
  final String message;
  final bool isRead;
  final String createdAt;
  final String? candidateName;
  final String? jobTitle;

  NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.candidateName,
    this.jobTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: json['created_at'].toString(),
      candidateName: json['candidate_name'],
      jobTitle: json['job_title'],
    );
  }
}
