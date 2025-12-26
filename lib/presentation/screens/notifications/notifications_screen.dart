import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }
  
  @override
  void dispose() {
      _tabController.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
            controller: _tabController,
            tabs: const [
                Tab(text: "All"),
                Tab(text: "Unread"),
            ]
        ),
        actions: [
            IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: "Mark all as read",
                onPressed: () {
                    context.read<NotificationProvider>().markAllAsRead();
                },
            )
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
              controller: _tabController,
              children: [
                  _buildList(provider.notifications, provider),
                  _buildList(provider.unreadNotifications, provider),
              ]
          );
        },
      ),
    );
  }

  Widget _buildList(List<NotificationItem> items, NotificationProvider provider) {
      if (items.isEmpty) {
          return const Center(child: Text("No notifications"));
      }
      
      return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (ctx, i) => const Divider(height: 1),
          itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                  key: Key(item.id.toString()),
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                      provider.deleteNotification(item.id);
                  },
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: item.isRead ? Colors.grey[300] : Colors.blue,
                          child: Icon(
                              _getIconForType(item.type), 
                              color: item.isRead ? Colors.grey : Colors.white
                          ),
                      ),
                      title: Text(
                          item.title, 
                          style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold
                          )
                      ),
                      subtitle: Text(
                          item.message, 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                      ),
                      trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text(item.timestamp, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              if (!item.isRead)
                                  const Icon(Icons.circle, size: 10, color: Colors.blue)
                          ],
                      ),
                      onTap: () {
                          Navigator.pushNamed(context, '/notification-detail', arguments: item);
                      },
                  ),
              );
          },
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
