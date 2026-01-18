import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Providers will be imported here
// Providers & Widgets
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/job_provider.dart';
import 'presentation/providers/saved_jobs_provider.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Notifications
  await NotificationService.initialize(navigatorKey);

  // Initialize Hive
  await Hive.initFlutter();
  // Register Adapters here later

  // Open Boxes
  await Hive.openBox('user_profile');
  await Hive.openBox('saved_jobs');

  // Initialize Ads
  // MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => SavedJobsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'IQRA CONNECT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
