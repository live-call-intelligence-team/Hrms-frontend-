class ProgressModel {
  final int id;
  final int userId;
  final int courseId;
  final double watchedMinutes;
  final double progressPercentage;
  final DateTime? updatedAt;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.watchedMinutes,
    required this.progressPercentage,
    this.updatedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      watchedMinutes: (json['watched_minutes'] as num).toDouble(),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
