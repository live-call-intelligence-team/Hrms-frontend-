import 'video_model.dart';

class CourseModel {
  final int? id;
  final String title;
  final String description;
  final dynamic category; // Can be int ID or Category object depending on API
  final String? thumbnailUrl;
  final String? duration; // e.g., "10h 30m"
  final bool isActive;
  final double? progress; // For enrolled courses
  final List<VideoModel> videos;

  CourseModel({
    this.id,
    required this.title,
    required this.description,
    this.category,
    this.thumbnailUrl,
    this.duration,
    this.isActive = true,
    this.progress,
    this.videos = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    var vList = json['videos'] as List? ?? [];
    List<VideoModel> videoList = vList.map((i) => VideoModel.fromJson(i)).toList();

    return CourseModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category_id'] ?? json['category'], 
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'] is int 
          ? (json['duration'] as int).toDouble().toString() 
          : json['duration'].toString(), // Handle variable types safely
      isActive: json['is_active'] ?? true,
      progress: json['progress'] != null ? (json['progress'] as num).toDouble() : null,
      videos: videoList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': category, 
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'is_active': isActive,
      'videos': videos.map((v) => v.toJson()).toList(),
    };
  }
}
