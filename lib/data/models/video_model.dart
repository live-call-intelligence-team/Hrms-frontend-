import 'quiz_checkpoint_model.dart';

class VideoModel {
  final int id;
  final int courseId;
  final String title;
  final String youtubeUrl;
  final double duration;
  final List<QuizCheckpointModel> checkpoints;

  VideoModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.youtubeUrl,
    this.duration = 0.0,
    this.checkpoints = const [],
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    var list = json['checkpoints'] as List? ?? [];
    List<QuizCheckpointModel> checkpointList = list
        .map((i) => QuizCheckpointModel.fromJson(i))
        .toList();

    return VideoModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'] ?? '',
      youtubeUrl: json['youtube_url'] ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      checkpoints: checkpointList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'youtube_url': youtubeUrl,
      'duration': duration,
      'checkpoints': checkpoints.map((x) => x.toJson()).toList(),
    };
  }
}
