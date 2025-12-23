import 'package:flutter/material.dart';
import '../../data/models/video_model.dart';
import '../../data/services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService = VideoService();

  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String? _error;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _videoService.getVideos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
