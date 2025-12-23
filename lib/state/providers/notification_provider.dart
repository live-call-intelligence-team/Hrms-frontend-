import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _service.getNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Temporarily toggle
      // We need to create a copy or make fields mutable. Fields are final.
      // Let's do it properly via API first then refresh or manual construction.
      // Manual construction for speed:
      final old = _notifications[index];
      _notifications[index] = NotificationModel(
        id: old.id,
        message: old.message,
        isRead: true,
        createdAt: old.createdAt,
        candidateName: old.candidateName,
        jobTitle: old.jobTitle
      );
      notifyListeners();

      final success = await _service.markNotificationRead(id);
      if (!success) {
        // Revert? Or just fetch again.
        await fetchNotifications();
      }
    }
  }

  Future<void> deleteNotification(int id) async {
     try {
       await _service.deleteNotification(id);
       _notifications.removeWhere((n) => n.id == id);
       notifyListeners();
     } catch (e) {
       _error = e.toString();
       notifyListeners();
     }
  }
}
