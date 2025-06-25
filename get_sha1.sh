#!/bin/bash

echo "=== Getting SHA-1 Fingerprint for Google Sign-In Setup ==="
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool not found. Please make sure Java is installed."
    exit 1
fi

echo "🔍 Looking for debug keystore..."

# Common debug keystore locations
KEYSTORE_LOCATIONS=(
    "$HOME/.android/debug.keystore"
    "$ANDROID_HOME/debug.keystore"
    "./android/debug.keystore"
)

KEYSTORE_PATH=""
for location in "${KEYSTORE_LOCATIONS[@]}"; do
    if [ -f "$location" ]; then
        KEYSTORE_PATH="$location"
        echo "✅ Found debug keystore at: $KEYSTORE_PATH"
        break
    fi
done

if [ -z "$KEYSTORE_PATH" ]; then
    echo "❌ Debug keystore not found. Trying to generate one..."
    mkdir -p "$HOME/.android"
    keytool -genkey -v -keystore "$HOME/.android/debug.keystore" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    KEYSTORE_PATH="$HOME/.android/debug.keystore"
fi

echo ""
echo "🔑 Extracting SHA-1 fingerprint..."
echo "--- Copy the SHA-1 fingerprint below ---"

keytool -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android | grep -E "SHA1|SHA-1"

echo ""
echo "📋 Steps to configure Google Sign-In:"
echo "1. Go to Firebase Console (https://console.firebase.google.com)"
echo "2. Select your project"
echo "3. Go to Project Settings > General"
echo "4. Scroll to 'Your apps' section"
echo "5. Click on your Android app"
echo "6. Add the SHA-1 fingerprint shown above"
echo "7. Download the updated google-services.json"
echo "8. Replace android/app/google-services.json with the new file"
echo ""
echo "📱 For release builds, you'll need to add the release SHA-1 as well"