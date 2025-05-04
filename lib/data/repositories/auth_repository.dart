import 'package:aastu_map/data/datasources/authentication_api.dart';
import 'package:aastu_map/data/models/user_model.dart';
import 'package:aastu_map/helpers/device_info_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AuthenticationRepository _authApi;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    AuthenticationRepository? authApi,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _authApi = authApi ?? AuthenticationRepository();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // User authentication status
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateUserLastActiveTime(userCredential.user!.uid);
      return userCredential;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final deviceInfo = await DeviceInfoHelper.getAllDeviceInfo();

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        firstname: firstname,
        lastname: lastname,
        email: email,
        isAnonymous: false,
        profilePic: "",
        phoneNumber: phoneNumber,
        deviceModel: deviceInfo['deviceModel'] ?? '',
        device_info: deviceInfo['device_info'] ?? '',
        osVersion: deviceInfo['osVersion'] ?? '',
        installedBuildNumber: deviceInfo['installedBuildNumber'] ?? '',
        created_time: DateTime.now(),
        last_active_time: DateTime.now(),
      );

      await _saveUserToFirestore(userModel);
      
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      final deviceInfo = await DeviceInfoHelper.getAllDeviceInfo();
      
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        firstname: 'Guest',
        email: '',
        profilePic: "",
        isAnonymous: true,
        deviceModel: deviceInfo['deviceModel'] ?? '',
        device_info: deviceInfo['device_info'] ?? '',
        osVersion: deviceInfo['osVersion'] ?? '',
        installedBuildNumber: deviceInfo['installedBuildNumber'] ?? '',
        created_time: DateTime.now(),
        last_active_time: DateTime.now(),
      );
      
      await _saveUserToFirestore(userModel);
      
      return userCredential;
    } catch (e) {
      throw Exception('Anonymous sign-in failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      print('[LOG AuthRepository] ========= Starting Google Sign-In flow');
      final user = await _authApi.signInWithGoogle();
      
      if (user != null) {
        print('[LOG AuthRepository] ========= User authenticated: ${user.uid}');
        print('[LOG AuthRepository] ========= Display Name: ${user.displayName}');
        print('[LOG AuthRepository] ========= Email: ${user.email}');
        print('[LOG AuthRepository] ========= Photo URL: ${user.photoURL}');
        
        final deviceInfo = await DeviceInfoHelper.getAllDeviceInfo();
        
        // Check if user already exists
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (!userDoc.exists) {
          print('[LOG AuthRepository] ========= Creating new user in Firestore');
          // Parse display name
          String firstName = '';
          String lastName = '';
          
          if (user.displayName != null && user.displayName!.isNotEmpty) {
            final nameParts = user.displayName!.split(' ');
            firstName = nameParts.first;
            if (nameParts.length > 1) {
              lastName = nameParts.sublist(1).join(' ');
            }
          }
          
          // Create a new user profile if it doesn't exist
          final userModel = UserModel(
            uid: user.uid,
            firstname: firstName,
            lastname: lastName,
            email: user.email ?? '',
            profilePic: user.photoURL ?? "",
            isAnonymous: false,
            deviceModel: deviceInfo['deviceModel'] ?? '',
            device_info: deviceInfo['device_info'] ?? '',
            osVersion: deviceInfo['osVersion'] ?? '',
            installedBuildNumber: deviceInfo['installedBuildNumber'] ?? '',
            created_time: DateTime.now(),
            last_active_time: DateTime.now(),
          );
          
          await _saveUserToFirestore(userModel);
          print('[LOG AuthRepository] ========= User saved to Firestore');
        } else {
          print('[LOG AuthRepository] ========= User already exists, updating last active time');
          // Just update the last active time
          await _updateUserLastActiveTime(user.uid);
        }
      } else {
        print('[LOG AuthRepository] ========= Google Sign-In was canceled or failed');
      }
      
      return user;
    } catch (e) {
      print('[LOG AuthRepository] ========= Error in Google sign-in: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authApi.signOut();
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('No user logged in or email already verified');
    }
  }

  // Check email verification
  Future<bool> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson());
  }

  // Update user's last active time
  Future<void> _updateUserLastActiveTime(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'last_active_time': DateTime.now().toIso8601String(),
        });
  }

  // Get user data
  Future<UserModel> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserModel.fromSnapshot(docSnapshot);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }
} 