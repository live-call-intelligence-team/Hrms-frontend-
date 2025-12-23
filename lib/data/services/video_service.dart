import '../models/video_model.dart';
import 'api_service.dart';

class VideoService {
  final ApiService _apiService = ApiService();

  Future<List<VideoModel>> getVideos() async {
    try {
      final response = await _apiService.get('/videos/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => VideoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  Future<VideoModel?> getVideo(int id) async {
    try {
      final response = await _apiService.get('/videos/$id');
      if (response.statusCode == 200) {
        return VideoModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load video: $e');
    }
  }
}
