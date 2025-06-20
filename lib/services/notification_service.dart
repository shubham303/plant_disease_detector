import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';

  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    final notifications = notificationsJson.map((notificationJson) {
      final Map<String, dynamic> notificationMap = json.decode(notificationJson);
      return NotificationItem.fromJson(notificationMap);
    }).toList();

    // Sort by timestamp (newest first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  static Future<void> addNotification(NotificationItem notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    await _saveNotifications(notifications);
  }

  static Future<void> markAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications(notifications);
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications(notifications);
  }

  static Future<void> _saveNotifications(List<NotificationItem> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = notifications.map((n) => json.encode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // Sample notifications for demo
  static Future<void> initializeSampleNotifications() async {
    final existing = await getNotifications();
    if (existing.isEmpty) {
      final sampleNotifications = [
        NotificationItem(
          id: '1',
          title: 'Weather Alert',
          message: 'Heavy rain expected tomorrow. Consider moving potted plants indoors.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'weather',
        ),
        NotificationItem(
          id: '2',
          title: 'Plant Care Reminder',
          message: 'Time to water your Tomato plants!',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          type: 'care',
        ),
        NotificationItem(
          id: '3',
          title: 'New Feature',
          message: 'Check out the new plant care chatbot in the My Plants section!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'general',
        ),
      ];

      for (final notification in sampleNotifications) {
        await addNotification(notification);
      }
    }
  }
}