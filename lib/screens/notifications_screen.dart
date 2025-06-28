import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await NotificationService.getNotifications();
      
      // Add dummy notifications if empty (for demo purposes)
      if (notifications.isEmpty) {
        await _addInitialDummyNotifications();
        final updatedNotifications = await NotificationService.getNotifications();
        setState(() {
          _notifications = updatedNotifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addInitialDummyNotifications() async {
    final dummyNotifications = [
      NotificationItem(
        id: '1',
        title: 'Welcome to PlantCare Pro!',
        message: 'Start your plant care journey by scanning your first plant. Our AI will help identify diseases and provide care tips.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'general',
      ),
      NotificationItem(
        id: '2',
        title: 'Perfect Weather for Plants',
        message: 'Sunny with moderate humidity today. Great time to check your outdoor plants and ensure they have enough water.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'weather',
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Weekly Plant Check Reminder',
        message: 'Time for your weekly plant inspection. Look for yellowing leaves, pests, or signs of disease.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'care',
      ),
      NotificationItem(
        id: '4',
        title: 'Plant Care Tip',
        message: 'Did you know? Most indoor plants prefer indirect sunlight. Direct sun can burn their leaves.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'general',
        isRead: true,
      ),
    ];

    for (final notification in dummyNotifications) {
      await NotificationService.addNotification(notification);
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (!notification.isRead) {
      await NotificationService.markAsRead(notification.id);
      _loadNotifications();
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    await NotificationService.deleteNotification(notification.id);
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification deleted'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0), // Yellowish white background
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer to center the title
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Notifications',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_notifications.isNotEmpty)
                          FutureBuilder<int>(
                            future: NotificationService.getUnreadCount(),
                            builder: (context, snapshot) {
                              final unreadCount = snapshot.data ?? 0;
                              return Text(
                                unreadCount > 0 
                                    ? '$unreadCount unread'
                                    : 'All caught up!',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B4FCF),
                      ),
                    )
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: RefreshIndicator(
                            onRefresh: _loadNotifications,
                            color: const Color(0xFF5B4FCF),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                return _buildNotificationCard(notification, index);
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FCF).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: Color(0xFF5B4FCF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll receive notifications about\nweather and plant care here',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF757575),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE57373),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (_) => _deleteNotification(notification),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _markAsRead(notification),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: notification.isRead ? const Color(0xFFE0E0E0) : const Color(0xFF5B4FCF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notification.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B4FCF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: const Color(0xFF9E9E9E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getNotificationTypeLabel(notification.type),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'weather':
        return Icons.wb_sunny_rounded;
      case 'care':
        return Icons.water_drop_rounded;
      case 'general':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'weather':
        return const Color(0xFFFF8F00);
      case 'care':
        return const Color(0xFF00ACC1);
      case 'general':
        return const Color(0xFF5B4FCF);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'weather':
        return 'Weather';
      case 'care':
        return 'Plant Care';
      case 'general':
        return 'General';
      default:
        return 'Notification';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}