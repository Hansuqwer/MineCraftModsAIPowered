#!/bin/bash

echo "🔨 Building Crafta APK..."

# Clean and get dependencies
echo "📦 Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Build APK
echo "🏗️ Building APK..."
if flutter build apk --debug; then
    echo "✅ Build successful!"
    
    # Create timestamped filename
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    APK_NAME="crafta_enhanced_${TIMESTAMP}.apk"
    
    # Move APK to Downloads
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        cp build/app/outputs/flutter-apk/app-debug.apk ~/Downloads/$APK_NAME
        echo "📱 APK saved to: ~/Downloads/$APK_NAME"
        echo "✅ APK moved successfully!"
    else
        echo "❌ APK file not found!"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
