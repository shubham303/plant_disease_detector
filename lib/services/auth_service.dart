import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Authentication
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // First sign out to ensure clean state
      await _googleSignIn.signOut();
      
      print('🔍 Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign-in was cancelled by user';
      }

      print('✅ Google user selected: ${googleUser.email}');
      print('🔐 Getting authentication tokens...');
      
      // Force refresh to get fresh tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('🔑 Access Token: ${googleAuth.accessToken != null ? "Present" : "Missing"}');
      print('🔑 ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');
      
      if (googleAuth.accessToken == null) {
        throw 'Failed to get Google access token. This might be due to:\n'
            '1. Incorrect SHA-1 fingerprint in Firebase\n'
            '2. Google Sign-In not properly enabled\n'
            '3. Network connectivity issues';
      }
      
      if (googleAuth.idToken == null) {
        throw 'Failed to get Google ID token. This might be due to:\n'
            '1. Missing Web Client ID in Firebase\n'
            '2. Incorrect OAuth configuration\n'
            '3. Firebase project configuration issues';
      }

      print('🔥 Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🚀 Signing in to Firebase...');
      final result = await _auth.signInWithCredential(credential);
      print('✅ Firebase sign-in successful!');
      
      return result;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      
      // Handle specific Google Sign-In errors
      if (e.toString().contains('ApiException')) {
        if (e.toString().contains('10')) {
          throw 'Google Sign-In configuration error. Please check:\n'
              '1. Add google-services.json file\n'
              '2. Enable Google Sign-In in Firebase Console\n'
              '3. Add SHA-1 fingerprint to Firebase project';
        } else if (e.toString().contains('12500')) {
          throw 'Google Sign-In service is missing or invalid';
        } else if (e.toString().contains('7')) {
          throw 'Network error. Please check your internet connection';
        }
      }
      throw 'Google sign-in failed: $e';
    }
  }


  // Apple Sign In (iOS/macOS only)
  Future<UserCredential?> signInWithApple() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      try {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        return await _auth.signInWithCredential(oauthCredential);
      } catch (e) {
        throw 'Apple sign-in failed: $e';
      }
    } else {
      throw 'Apple Sign-In is only available on iOS and macOS devices';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔐 Starting sign out process...');
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      print('✅ Sign out completed successfully');
    } catch (e) {
      print('⚠️ Error during sign out: $e');
      // Even if Google Sign-In sign out fails, make sure Firebase signs out
      await _auth.signOut();
      print('✅ Firebase sign out completed as fallback');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Sign out from Google first to avoid conflicts
        await _googleSignIn.signOut();
        // Delete the Firebase user account
        await user.delete();
      } else {
        throw 'No user is currently signed in';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account: $e';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}