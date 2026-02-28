class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.tripId,
    this.requestId,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final int? tripId;
  final int? requestId;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      tripId: json['trip_id'] as int?,
      requestId: json['request_id'] as int?,
    );
  }
}

class NotificationSummary {
  NotificationSummary({required this.notifications, required this.unreadCount});

  final List<AppNotification> notifications;
  final int unreadCount;

  int get totalCount => unreadCount;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    final rawNotifications =
        json['notifications'] as List<dynamic>? ?? const [];

    return NotificationSummary(
      notifications: rawNotifications
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
