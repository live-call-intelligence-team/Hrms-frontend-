import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/notification_provider.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: provider.notifications.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = provider.notifications[index];
              return Dismissible(
                key: Key(note.id.toString()),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  provider.deleteNotification(note.id);
                },
                child: ListTile(
                  tileColor: note.isRead ? null : Colors.blue.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: note.isRead ? Colors.grey : Colors.blue,
                    radius: 5,
                  ),
                  title: Text(
                    note.message, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(
                    note.createdAt.substring(0, 10), // Simple date truncate
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    provider.markAsRead(note.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: note)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
