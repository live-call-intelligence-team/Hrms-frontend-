class QuizHistoryModel {
  final int id;
  final int userId;
  final int courseId;
  final int videoId;
  final int checkpointId;
  final String question;
  final String answer;
  final bool result;
  final DateTime? completedAt;

  QuizHistoryModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.videoId,
    required this.checkpointId,
    required this.question,
    required this.answer,
    required this.result,
    this.completedAt,
  });

  factory QuizHistoryModel.fromJson(Map<String, dynamic> json) {
    return QuizHistoryModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      videoId: json['video_id'],
      checkpointId: json['checkpoint_id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      result: json['result'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
