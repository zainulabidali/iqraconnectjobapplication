import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iqra_connect/core/services/bannerAdWidget.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification =
                  notifications[index].data() as Map<String, dynamic>;

              // 🔹 Extract fields matching backend structure
              final title = notification['title'] ?? 'New Notification';
              final jobType = notification['jobType'] ?? '';
              final district = notification['district'] ?? '';
              final state = notification['state'] ?? '';

              // Format location
              String location = '';
              if (district.isNotEmpty && state.isNotEmpty) {
                location = '$district, $state';
              } else {
                location = district.isNotEmpty
                    ? district
                    : (state.isNotEmpty ? state : 'Location N/A');
              }

              // Format time
              final timestamp = notification['createdAt'] as Timestamp?;
              final timeStr = timestamp != null
                  ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                  : 'Just now';

              return _NotificationItem(
                title: title,
                location: location,
                jobType: jobType,
                time: timeStr,
              );
            },
          );
        },
      ),
      bottomNavigationBar: BannerAdWidget(),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String location;
  final String jobType;
  final String time;

  const _NotificationItem({
    required this.title,
    required this.location,
    required this.jobType,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),

          // Location & Job Type Row
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              if (jobType.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.white30)),
                const SizedBox(width: 8),
                Text(
                  jobType,
                  style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Time
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              time,
              style: const TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
