import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _apiService.get('/notifications/');
      if (response.data is List) {
        return (response.data as List).map((e) => NotificationItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.put('/notifications/$id/read/');
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> markAllAsRead() async {
      try {
           await _apiService.put('/notifications/mark-all-read/');
      } catch (e) {
          rethrow;
      }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _apiService.delete('/notifications/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
