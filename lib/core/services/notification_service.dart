import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/job_model.dart';
import '../../presentation/screens/jobs/job_detail_screen.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> initialize(GlobalKey<NavigatorState> navKey) async {
    navigatorKey = navKey;

    try {
      // 1. Request Permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }

    // 2. Initialize Local Notifications (for foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          try {
            final data = json.decode(details.payload!);
            _handleMessageNavigation(data);
          } catch (e) {
            debugPrint('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 4. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageNavigation(message.data);
    });

    // Check if app was opened from terminated state
    try {
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageNavigation(initialMessage.data);
      }
    } catch (e) {
      debugPrint('Error getting initial message: $e');
    }

    // 5. Subscribe to Topics
    try {
      await _fcm.subscribeToTopic('all_users');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }

    // 6. Save Token
    try {
      await saveTokenToFirestore();
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  static Future<void> saveTokenToFirestore() async {
    try {
      String? token = await _fcm.getToken();
      User? user = FirebaseAuth.instance.currentUser;

      if (token != null && user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error in saveTokenToFirestore: $e');
    }
  }

  static void _showLocalNotification(RemoteMessage message) async {
   const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'job_alerts',
  'Job Alerts',
  importance: Importance.max,
  priority: Priority.high,
  icon: 'ic_notification', // 🔥 force custom icon
);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: json.encode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  static void _handleMessageNavigation(Map<String, dynamic> data) async {
    if (data['jobId'] != null && navigatorKey != null) {
      try {
        // Fetch job details and navigate
        final doc = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(data['jobId'])
            .get();

        if (doc.exists) {
          final job = JobModel.fromSnapshot(doc);
          navigatorKey!.currentState?.push(
            MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
          );
        } else {
          debugPrint('Job not found for notification navigation');
        }
      } catch (e) {
        debugPrint('Error navigating from notification: $e');
      }
    }
  }
}
