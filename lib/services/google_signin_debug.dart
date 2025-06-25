import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInDebug {
  static Future<void> runDiagnostics() async {
    if (kDebugMode) {
      print('\n=== Google Sign-In Diagnostics ===');
      
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        
        print('📱 Platform: ${defaultTargetPlatform.name}');
        print('🔧 Google Sign-In initialized: ${googleSignIn.toString()}');
        
        // Check if user is already signed in
        final currentUser = await googleSignIn.signInSilently();
        print('👤 Current signed-in user: ${currentUser?.email ?? "None"}');
        
        // Check available accounts
        print('📋 Checking available accounts...');
        final accounts = await googleSignIn.signInSilently(suppressErrors: true);
        print('📊 Silent sign-in result: ${accounts?.email ?? "No cached account"}');
        
        print('=== End Diagnostics ===\n');
      } catch (e) {
        print('❌ Diagnostics failed: $e');
      }
    }
  }
  
  static void logGoogleSignInConfig() {
    if (kDebugMode) {
      print('\n=== Google Sign-In Configuration ===');
      print('🔍 Check these items in Firebase Console:');
      print('1. Project Settings > General > Your apps');
      print('2. Verify SHA-1 fingerprint is added');
      print('3. Authentication > Sign-in method > Google (Enabled)');
      print('4. Make sure google-services.json is in android/app/');
      print('================================\n');
    }
  }
}