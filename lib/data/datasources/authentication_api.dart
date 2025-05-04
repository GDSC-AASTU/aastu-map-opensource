import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthenticationRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      print('[LOG GoogleSignIn] ========= Starting Google Sign-In flow');
      
      // Force sign out first to ensure a fresh authentication
      await _googleSignIn.signOut();
      
      // Start the interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('[LOG GoogleSignIn] ========= Sign-in canceled by user');
        return null; // User canceled the sign-in process
      }
      
      print('[LOG GoogleSignIn] ========= Obtained Google account: ${googleUser.email}');
      print('[LOG GoogleSignIn] ========= Display name: ${googleUser.displayName}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('[LOG GoogleSignIn] ========= Access token available: ${googleAuth.accessToken != null}');
      print('[LOG GoogleSignIn] ========= ID token available: ${googleAuth.idToken != null}');

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      print('[LOG GoogleSignIn] ========= Created AuthCredential, signing in to Firebase');

      // Sign in to Firebase with the Google Auth credentials
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      print('[LOG GoogleSignIn] ========= Firebase sign-in successful');
      print('[LOG GoogleSignIn] ========= User UID: ${userCredential.user?.uid}');
      print('[LOG GoogleSignIn] ========= User name: ${userCredential.user?.displayName}');
      print('[LOG GoogleSignIn] ========= User email: ${userCredential.user?.email}');

      return userCredential.user;
    } catch (e) {
      print('[LOG GoogleSignIn] ========= Error during Google Sign-In: $e');
      rethrow; // Rethrow to allow the repository to handle it
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('[LOG GoogleSignIn] ========= Error during sign out: $e');
      rethrow;
    }
  }

  // Get the current user
  User? get currentUser => _firebaseAuth.currentUser;
}
