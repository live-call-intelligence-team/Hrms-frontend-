class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String timestamp;
  bool isRead;
  final String type; // e.g., 'info', 'alert', 'success'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'info',
    );
  }
}
