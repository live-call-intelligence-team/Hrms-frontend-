import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Parse date if possible
    DateTime? date;
    try {
      date = DateTime.parse(notification.createdAt);
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detail')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (date != null)
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 32),
            if (notification.candidateName != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text('Related To:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(notification.candidateName!),
                subtitle: notification.jobTitle != null ? Text(notification.jobTitle!) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
