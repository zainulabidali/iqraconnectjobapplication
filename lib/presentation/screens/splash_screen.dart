import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_creation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Show splash for at least 3 seconds
    await Future.delayed(const Duration(seconds:5));

    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is NOT logged in
      _navigateTo(const LoginScreen());
    } else {
      // User is logged in, check profile
      try {
        await profileProvider.fetchUserProfile(user.uid);
        final profile = profileProvider.currentUserProfile;

        if (profile != null && profile.profileCompleted) {
          // Profile exists and is completed
          _navigateTo(const HomeScreen());
        } else {
          // Profile not created or not completed
          _navigateTo(const ProfileCreationScreen());
        }
      } catch (e) {
        // Handle error (e.g., fetch failed) - maybe show login or retry
        _navigateTo(const LoginScreen());
      }
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false, // Prevent back navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/animation.gif',
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
