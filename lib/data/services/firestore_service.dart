import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersCollection => _db.collection('users');

  // Create or Update User
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // Get User
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error getting user: $e");
      rethrow;
    }
  }

  // Check if profile exists
  Future<bool> checkUserExists(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
