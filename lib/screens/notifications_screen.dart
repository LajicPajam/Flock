import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_summary.dart';
import '../state/app_state.dart';
import 'trip_detail_screen.dart';
import 'ui_shell.dart';

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
      context.read<AppState>().loadNotifications();
    });
  }

  Future<void> _openNotification(AppNotification notification) async {
    final appState = context.read<AppState>();
    if (!notification.isRead) {
      await appState.markNotificationRead(notification.id);
    }

    if (!mounted) {
      return;
    }

    if (notification.tripId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TripDetailScreen(tripId: notification.tripId!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifications = appState.notifications.notifications;

    return UiShell(
      title: 'Notifications',
      child: RefreshIndicator(
        onRefresh: () => context.read<AppState>().loadNotifications(),
        child: notifications.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No notifications yet.')),
                ],
              )
            : ListView(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: appState.notifications.unreadCount == 0
                          ? null
                          : () => context
                                .read<AppState>()
                                .markAllNotificationsRead(),
                      child: const Text('Mark All Read'),
                    ),
                  ),
                  ...notifications.map(
                    (notification) => Card(
                      child: ListTile(
                        leading: Icon(
                          notification.isRead
                              ? Icons.notifications_none
                              : Icons.mark_email_unread_outlined,
                        ),
                        title: Text(notification.title),
                        subtitle: Text(
                          '${notification.body}\n${notification.createdAt.toLocal()}',
                        ),
                        isThreeLine: true,
                        trailing: notification.isRead
                            ? null
                            : const Icon(Icons.brightness_1, size: 10),
                        onTap: () => _openNotification(notification),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
