import 'api_service.dart';
import '../models/progress_model.dart';
import '../models/quiz_history_model.dart';
import '../models/quiz_checkpoint_model.dart';

class LearningService {
  final ApiService _apiService = ApiService();

  Future<List<ProgressModel>> getProgress({int? userId}) async {
    try {
      String endpoint = '/progress/';
      if (userId != null) {
        endpoint += '?user_id=$userId';
      }
      
      final response = await _apiService.get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProgressModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    }
  }

  Future<List<QuizHistoryModel>> getQuizHistory(int userId) async {
    try {
      final response = await _apiService.get('/quiz-history/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => QuizHistoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load quiz history: $e');
    }
  }

  Future<List<QuizCheckpointModel>> getCheckpoints() async {
    try {
      final response = await _apiService.get('/checkpoints/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => QuizCheckpointModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load checkpoints: $e');
    }
  }
}
