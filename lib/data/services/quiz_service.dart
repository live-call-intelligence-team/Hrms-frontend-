import 'api_service.dart';

class QuizService {
  final ApiService _apiService = ApiService();

  Future<bool> submitQuiz(int checkpointId, String answer) async {
    try {
      final response = await _apiService.post(
        '/quiz-history/',
        data: {
          'checkpoint_id': checkpointId,
          'answer_given': answer,
        },
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Backend returns "is_correct" usually
        final data = response.data;
        return data['is_correct'] ?? true; 
      }
      return false;
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }
}
