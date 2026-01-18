import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';
import 'saved_jobs_provider.dart';
import '../../core/services/notification_service.dart';
import '../screens/auth/login_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();
      if (credential == null) return false;

      // Save FCM Token
      await NotificationService.saveTokenToFirestore();

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    // Clear Hive Data
    await Hive.box('user_profile').clear();
    await Hive.box('saved_jobs').clear();

    if (context.mounted) {
      Provider.of<ProfileProvider>(context, listen: false).clearData();
      Provider.of<SavedJobsProvider>(context, listen: false).clearData();
    }

    await _authService.signOut();
    _user = null;
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
