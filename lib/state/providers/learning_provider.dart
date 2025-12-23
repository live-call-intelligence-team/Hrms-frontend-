import 'package:flutter/material.dart';
import '../../data/models/progress_model.dart';
import '../../data/models/quiz_history_model.dart';
import '../../data/models/quiz_checkpoint_model.dart';
import '../../data/services/learning_service.dart';

class LearningProvider extends ChangeNotifier {
  final LearningService _learningService = LearningService();

  List<ProgressModel> _progressList = [];
  List<QuizHistoryModel> _quizHistory = [];
  List<QuizCheckpointModel> _checkpoints = [];
  bool _isLoading = false;
  String? _error;

  List<ProgressModel> get progressList => _progressList;
  List<QuizHistoryModel> get quizHistory => _quizHistory;
  List<QuizCheckpointModel> get checkpoints => _checkpoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProgress(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _progressList = await _learningService.getProgress(userId: userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizHistory(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quizHistory = await _learningService.getQuizHistory(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCheckpoints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _checkpoints = await _learningService.getCheckpoints();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
