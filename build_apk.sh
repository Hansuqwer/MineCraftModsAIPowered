#!/bin/bash

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# Get current timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_NUMBER=$(date +%s)

echo "🔨 Building APK with timestamp: $TIMESTAMP"

# Build APK with timestamp
flutter build apk --debug --build-name=$TIMESTAMP --build-number=$BUILD_NUMBER

# Find the APK file
APK_FILE=$(find build -name "*.apk" -type f 2>/dev/null | head -1)

if [ -n "$APK_FILE" ]; then
    echo "✅ APK found: $APK_FILE"
    
    # Create Downloads directory if it doesn't exist
    mkdir -p ~/Downloads
    
    # Copy APK to Downloads with timestamp
    cp "$APK_FILE" ~/Downloads/crafta_${TIMESTAMP}.apk
    
    echo "📱 APK copied to: ~/Downloads/crafta_${TIMESTAMP}.apk"
    echo "📁 File size: $(du -h ~/Downloads/crafta_${TIMESTAMP}.apk | cut -f1)"
else
    echo "❌ APK not found in build directory"
    echo "📁 Build directory contents:"
    find build -type f 2>/dev/null || echo "No build directory found"
fi
