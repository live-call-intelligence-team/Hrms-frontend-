import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationItem notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as read when opened
    if (!widget.notification.isRead) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<NotificationProvider>().markAsRead(widget.notification.id);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detail')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                      children: [
                           Icon(_getIconForType(widget.notification.type), size: 40, color: Colors.blue),
                           const SizedBox(width: 16),
                           Expanded(
                               child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                       Text(widget.notification.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                       Text(widget.notification.timestamp, style: const TextStyle(color: Colors.grey)),
                                   ],
                               ),
                           )
                      ],
                  ),
                  const Divider(height: 32),
                  Text(widget.notification.message, style: const TextStyle(fontSize: 16, height: 1.5)),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons placeholder
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                          OutlinedButton(
                              onPressed: () {
                                  context.read<NotificationProvider>().deleteNotification(widget.notification.id);
                                  Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text("Delete"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                          )
                      ],
                  )
              ],
          ),
      ),
    );
  }

  IconData _getIconForType(String type) {
      switch(type) {
          case 'alert': return Icons.warning;
          case 'success': return Icons.check_circle;
          case 'info': 
          default: return Icons.notifications;
      }
  }
}
