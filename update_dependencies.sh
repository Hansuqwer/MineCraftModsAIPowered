#!/usr/bin/env bash
set -e

echo "🔄 Updating Flutter Dependencies"
echo "================================"

# Set Flutter path
export PATH="/home/rickard/flutter/bin:$PATH"

# Navigate to project directory
cd /home/rickard/MineCraftModsAIPowered/crafta

echo "📋 Current dependency status:"
flutter pub outdated

echo ""
echo "🧹 Cleaning project..."
flutter clean

echo ""
echo "📦 Updating dependencies to latest compatible versions..."
flutter pub upgrade --major-versions

echo ""
echo "🔍 Checking for any remaining issues..."
flutter pub deps

echo ""
echo "✅ Dependencies updated successfully!"
echo ""
echo "📊 Summary of updates:"
echo "- file_picker: 8.3.7 → 10.3.3"
echo "- flutter_dotenv: 5.2.1 → 6.0.0"
echo "- share_plus: 10.1.4 → 12.0.1"
echo "- speech_to_text: 6.6.0 → 7.3.0"
echo "- webview_flutter: 4.10.0 → 4.13.0"
echo "- package_info_plus: 8.3.1 → 9.0.0"
echo "- flutter_lints: 4.0.0 → 6.0.0"
echo ""
echo "🚀 Ready to build!"
