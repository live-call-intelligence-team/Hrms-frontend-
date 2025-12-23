import 'api_service.dart';

class ProgressService {
  final ApiService _apiService = ApiService();

  Future<void> updateProgress(int videoId, int percentage, int durationWatched) async {
    try {
      final response = await _apiService.post(
        '/progress/',
        data: {
          'video_id': videoId,
          'percentage': percentage,
          'duration_watched': durationWatched,
        },
      );
      // We don't necessarily need to return anything if it's just a fire-and-forget update or status check
    } catch (e) {
      // Log error or silently fail for progress updates to avoid interrupting user
      print('Failed to update progress: $e');
    }
  }
}
