# Google Sign-In ID Token Missing - Troubleshooting Guide

## 🔍 The Issue
Getting "ID Token missing" error means Google Sign-In is working partially, but not generating the ID token required for Firebase Authentication.

## 🛠️ Fixes to Try (in order)

### 1. **Enable Google Sign-In API in Google Cloud Console**
This is the most common cause of missing ID tokens:

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project: `plant-care-app-e2fe9`
3. Go to **APIs & Services** → **Library**
4. Search for "Google Sign-In API" or "Google+ API"
5. Click on it and press **ENABLE**
6. Also enable "Identity and Access Management (IAM) API"

### 2. **Check OAuth 2.0 Configuration**
1. In Google Cloud Console → **APIs & Services** → **Credentials**
2. Look for your OAuth 2.0 client IDs
3. Make sure you have both:
   - **Android client** (with SHA-1 fingerprint)
   - **Web client** (for server-side auth)

### 3. **Verify Firebase Authentication Setup**
1. Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Google**
3. Make sure it's **Enabled**
4. Verify the **Web SDK configuration** shows your Web Client ID

### 4. **Check OAuth Consent Screen**
1. Google Cloud Console → **APIs & Services** → **OAuth consent screen**
2. Make sure the app is configured with:
   - App name
   - User support email
   - Scopes include `email` and `profile`

### 5. **Try Alternative Implementation**

Replace the Google Sign-In method with this version:

```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut();
    
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw 'Sign-in cancelled';

    // Get fresh authentication tokens
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;

    // Check if we have the required tokens
    if (googleAuth.idToken == null) {
      // Try to get fresh tokens
      await googleUser.clearAuthCache();
      final freshAuth = await googleUser.authentication;
      
      if (freshAuth.idToken == null) {
        throw 'Failed to get ID token. Please check:\n'
            '1. Google Sign-In API is enabled in Google Cloud Console\n'
            '2. OAuth consent screen is properly configured\n'
            '3. Web client ID is configured in Firebase';
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: freshAuth.accessToken,
        idToken: freshAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } catch (e) {
    throw 'Google sign-in failed: $e';
  }
}
```

## 🔧 Quick Test Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check if Google Services plugin is working
flutter packages get
```

## 📋 Verification Checklist

- [ ] Google Sign-In API enabled in Google Cloud Console
- [ ] OAuth consent screen configured
- [ ] Both Android and Web OAuth clients exist
- [ ] SHA-1 fingerprint added to Android client
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] `google-services.json` is in `android/app/`
- [ ] Google Services plugin added to `build.gradle`

## 🆘 If Still Not Working

The issue might be that your Google Cloud project and Firebase project are not properly linked. Try:

1. **Re-link Firebase to Google Cloud:**
   - Firebase Console → Project Settings → General
   - Click "Google Cloud Platform (GCP) resource location"
   - Make sure it matches your Google Cloud project

2. **Create new OAuth credentials:**
   - Delete existing OAuth clients in Google Cloud Console
   - Re-add them with the same SHA-1 fingerprint
   - Download new `google-services.json`

3. **Use Firebase CLI to reconfigure:**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase projects:list
   flutterfire configure
   ```