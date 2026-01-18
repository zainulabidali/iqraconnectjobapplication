import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.darkBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationItem(
            title: 'Welcome to Job Finder App',
            message: 'We are glad to have you here. Start exploring jobs now!',
            time: 'Just now',
            isUnread: true,
          ),
          _NotificationItem(
            title: 'New Features',
            message: 'Check out the new Saved Jobs feature.',
            time: '1 hour ago',
            isUnread: true,
          ),
          _NotificationItem(
            title: 'Coming Soon',
            message: 'Real-time notifications will be available soon.',
            time: '1 day ago',
            isUnread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.cardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
