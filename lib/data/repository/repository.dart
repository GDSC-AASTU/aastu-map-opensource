import 'package:aastu_map/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<UserModel> getUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Log the raw Firestore document data
        print("Firestore Document Data: ${userDoc.data()}");

        return UserModel.fromSnapshot(
            userDoc as DocumentSnapshot<Map<String, dynamic>>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Log the data being updated
      print("Updating Firestore Document with Data: ${user.toJson()}");

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'firstname': user.firstname,
        'lastname': user.lastname,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'last_active_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error updating profile: $e");
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Separate method to update password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePassword(newPassword);
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print("Error updating password: $e");
      throw Exception('Failed to update password: $e');
    }
  }
}