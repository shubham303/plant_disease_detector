# Google Sign-In Setup Guide

## 🚀 Quick Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" or "Add project"
3. Enter project name (e.g., "plant-care-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App to Firebase
1. In Firebase Console, click "Add app" → Android
2. Package name: `com.example.plant_disease_detector`
3. App nickname: "Plant Care Android"
4. Click "Register app"

### 3. Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Click "Google" → Enable → Save

### 4. Get SHA-1 Fingerprint
Run the provided script:
```bash
./get_sha1.sh
```

Or manually:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 5. Add SHA-1 to Firebase
1. In Firebase Console → Project Settings → General
2. Scroll to "Your apps" → Android app
3. Click "Add fingerprint"
4. Paste the SHA-1 fingerprint
5. Click "Save"

### 6. Download google-services.json
1. In Firebase Console → Project Settings → General
2. Scroll to "Your apps" → Android app
3. Click "google-services.json" download button
4. Replace `android/app/google-services.json` with downloaded file

### 7. Update Firebase Configuration
Replace the demo values in `lib/firebase_options.dart` with your actual Firebase project values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-messaging-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 8. Test the Setup
```bash
flutter clean
flutter pub get
flutter run
```

## 🔧 Troubleshooting

### Error: ApiException 10
- **Cause**: Missing or incorrect google-services.json
- **Solution**: Download correct google-services.json from Firebase Console

### Error: ApiException 12500
- **Cause**: Google Play Services missing/outdated
- **Solution**: Update Google Play Services on device

### Error: ApiException 7
- **Cause**: Network connectivity issues
- **Solution**: Check internet connection

### SHA-1 Fingerprint Issues
- **Debug builds**: Use debug keystore SHA-1
- **Release builds**: Use release keystore SHA-1
- **Multiple SHA-1s**: Add all variants to Firebase

## 📱 Additional Setup

### For iOS (Optional)
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Add to `ios/Runner/GoogleService-Info.plist`

### For Web (Optional)
1. Add Web app in Firebase Console
2. Copy config to `lib/firebase_options.dart` web section

## 🔐 Security Notes

- Keep `google-services.json` secure
- Add to `.gitignore` for public repositories
- Use different Firebase projects for dev/prod
- Enable Firebase Security Rules