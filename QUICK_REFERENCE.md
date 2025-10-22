# 🚀 Quick Reference - Crafta Minecraft AI

## 📱 **APK Ready**
```bash
# Location
build/app/outputs/flutter-apk/app-debug.apk

# Install
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 🔧 **Environment Setup**
```bash
# Add Flutter to PATH
export PATH="/home/rickard/flutter/bin:$PATH"

# Navigate to project
cd /home/rickard/MineCraftModsAIPowered/crafta

# Build APK
flutter build apk --debug
```

## 🔑 **OAuth Configuration**
```env
# .env file
GOOGLE_CLOUD_PROJECT_ID=unified-ruler-475913-r5
GOOGLE_CLOUD_CLIENT_ID=80309731075-j184cbi2pddojfo6vdioaipm13j0vqlt.apps.googleusercontent.com
```

## 📦 **Package Info**
- **Package Name:** `com.example.crafta`
- **SHA-1:** `97:10:54:5D:AE:8A:68:13:BE:07:83:64:52:95:02:AC:FD:EB:E7:A2`
- **Project ID:** `unified-ruler-475913-r5`

## 🎯 **Current Status**
- ✅ All bugs fixed
- ✅ OAuth configured
- ✅ APK built successfully
- ✅ Ready for testing

## 🐛 **Common Issues**
1. **Flutter not found:** Add to PATH
2. **OAuth fails:** Add SHA-1 to Google Cloud Console
3. **3D preview stuck:** OAuth not configured (shows fallback)

## 📋 **Next Steps**
1. Test APK installation
2. Complete OAuth setup in Google Cloud Console
3. Test real 3D image generation
4. Implement cost controls if needed