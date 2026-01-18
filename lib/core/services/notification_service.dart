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

    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Initialize Local Notifications (for foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = json.decode(details.payload!);
          _handleMessageNavigation(data);
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
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage.data);
    }

    // 5. Subscribe to Topics
    await _fcm.subscribeToTopic('new_jobs');

    // 6. Save Token
    await saveTokenToFirestore();
  }

  static Future<void> saveTokenToFirestore() async {
    String? token = await _fcm.getToken();
    User? user = FirebaseAuth.instance.currentUser;

    if (token != null && user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  static void _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'job_alerts',
          'Job Alerts',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  static void _handleMessageNavigation(Map<String, dynamic> data) {
    if (data['jobId'] != null && navigatorKey != null) {
      // Fetch job details and navigate
      FirebaseFirestore.instance
          .collection('jobs')
          .doc(data['jobId'])
          .get()
          .then((doc) {
            if (doc.exists) {
              final job = JobModel.fromSnapshot(doc);
              navigatorKey!.currentState?.push(
                MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
              );
            }
          });
    }
  }
}
