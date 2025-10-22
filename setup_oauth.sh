#!/bin/bash

# OAuth Setup Script for Crafta Minecraft AI
# This script helps you get the SHA-1 fingerprint needed for OAuth setup

echo "🔧 Crafta OAuth Setup Helper"
echo "=============================="
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool not found. Please install Java JDK first."
    echo "   On Ubuntu/Debian: sudo apt install openjdk-11-jdk"
    echo "   On Arch: sudo pacman -S jdk11-openjdk"
    exit 1
fi

echo "📱 Getting SHA-1 fingerprint for OAuth setup..."
echo ""

# Get debug keystore SHA-1
echo "🔍 Debug Keystore SHA-1 (for development):"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep "SHA1:"

echo ""
echo "📋 Next Steps:"
echo "1. Go to Google Cloud Console: https://console.cloud.google.com/"
echo "2. Create/select your project"
echo "3. Enable Vertex AI API"
echo "4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID"
echo "5. Choose 'Android' application type"
echo "6. Package name: com.crafta.minecraft.ai"
echo "7. SHA-1 fingerprint: [Use the SHA-1 from above]"
echo "8. Copy the Client ID and update .env file"
echo ""
echo "📝 Update .env file with:"
echo "GOOGLE_CLOUD_PROJECT_ID=your-real-project-id"
echo "GOOGLE_CLOUD_CLIENT_ID=your-client-id.apps.googleusercontent.com"
echo ""
echo "✅ After updating .env, run: flutter pub get && flutter build apk --debug"