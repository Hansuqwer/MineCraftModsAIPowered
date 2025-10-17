#!/bin/bash

# Get current timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Find the APK file
APK_FILE=$(find build -name "*.apk" -type f | head -1)

if [ -n "$APK_FILE" ]; then
    # Copy to Downloads with timestamp
    cp "$APK_FILE" ~/Downloads/crafta_swedish_${TIMESTAMP}.apk
    echo "✅ APK copied to Downloads: crafta_swedish_${TIMESTAMP}.apk"
    echo "📱 File location: ~/Downloads/crafta_swedish_${TIMESTAMP}.apk"
else
    echo "❌ No APK file found in build directory"
    echo "🔍 Searching for APK files..."
    find . -name "*.apk" -type f
fi
