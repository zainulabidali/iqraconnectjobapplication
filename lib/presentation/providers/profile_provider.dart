import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/firestore_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUserProfile;
  bool _isLoading = false;

  UserModel? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUserProfile = await _firestoreService.getUser(uid);
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkProfileExists(String uid) async {
    return await _firestoreService.checkUserExists(uid);
  }

  Future<void> saveUserProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.saveUser(user);
      _currentUserProfile = user;
    } catch (e) {
      print("Error saving profile: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _currentUserProfile = null;
    notifyListeners();
  }
}
