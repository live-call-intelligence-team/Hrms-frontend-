class QuizCheckpointModel {
  final int id;
  final int videoId;
  final int courseId;
  final String question;
  final String choices; // Stored as CSV string or JSON string from backend
  final String correctAnswer;
  final double timestamp;
  final bool required;

  QuizCheckpointModel({
    required this.id,
    required this.videoId,
    required this.courseId,
    required this.question,
    required this.choices,
    required this.correctAnswer,
    required this.timestamp,
    this.required = true,
  });

  factory QuizCheckpointModel.fromJson(Map<String, dynamic> json) {
    return QuizCheckpointModel(
      id: json['id'],
      videoId: json['video_id'],
      courseId: json['course_id'],
      question: json['question'],
      choices: json['choices'], 
      correctAnswer: json['correct_answer'],
      timestamp: (json['timestamp'] as num).toDouble(),
      required: json['required'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'course_id': courseId,
      'question': question,
      'choices': choices,
      'correct_answer': correctAnswer,
      'timestamp': timestamp,
      'required': required,
    };
  }
}
