# Deployment & STEP 1 Testing Instructions

**Date**: October 20, 2025
**Status**: Ready to Deploy
**Target**: Android Device

---

## Quick Start (5 minutes)

```bash
# 1. Build the clean APK
flutter build apk --release

# 2. Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# 3. Open app and navigate to /voice-test screen

# 4. Run tests and report results
```

---

## Detailed Deployment Guide

### Step 1: Prerequisites

**Required**:
- ✅ Android device (real device, NOT emulator)
- ✅ USB cable
- ✅ Android SDK tools (adb)
- ✅ USB debugging enabled on device
- ✅ Microphone working on device
- ✅ Speaker/headphones working on device

**Check Prerequisites**:
```bash
# Verify adb is installed
adb --version

# List connected devices
adb devices

# Should show:
# List of attached devices
# xxxxxx  device  (your phone)
```

### Step 2: Build APK

Navigate to project directory and build:

```bash
cd /home/rickard/MineCraftModsAIPowered/crafta

# Build release APK
flutter build apk --release

# Expected output:
# Running Gradle task 'assembleRelease'...
# ✓ Built build/app/outputs/flutter-apk/app-release.apk (67.1MB)
```

**Build output location**:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Install on Device

**Option A: Via ADB (Recommended)**

```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Expected output:
# Installing build/app/outputs/flutter-apk/app-release.apk
# Success
```

**Option B: Manual Installation**

1. Copy APK to computer download folder
2. Connect phone via USB
3. In file manager on phone: Downloads folder
4. Tap APK → Install

### Step 4: First Launch

When app starts for first time:

1. **Permission Prompt**: "Allow Crafta to access microphone?"
   - Tap: **ALLOW** ✅

2. **Permission Prompt**: "Allow Crafta to access files?"
   - Tap: **ALLOW** ✅

3. **Welcome Screen**: You should see Crafta welcome screen
   - This confirms basic app works

### Step 5: Navigate to Voice Test Screen

From the main app, navigate to `/voice-test`:

**Method 1: If app has debug menu**
- Look for Settings or Debug option
- Find URL/Route input
- Type: `/voice-test`
- Press Go

**Method 2: Direct link (if implemented)**
- Some screens may have "Test Voice" link
- Tap to navigate to test screen

**Method 3: Via Flutter logs (if running via flutter run)**
```bash
# In terminal running flutter run:
# You might see a menu - look for route options
```

### Step 6: Verify Screen Loaded

Once on `/voice-test` screen, you should see:

```
════════════════════════════════════════════
          Voice Service Test (T1.1 & T1.2)
════════════════════════════════════════════

[Status Cards]
✅ Speech-to-Text    (or ❌ if failed)
✅ Text-to-Speech    (or ❌ if failed)

[Overall Status]
🟢 Ready for testing   (or 🔴 if services failed)

[Test Buttons]
- Test Speech Input
- Test TTS: Hello
- Test TTS: Celebration
- Test Complete Voice Loop

[Test Log]
(empty or showing initialization messages)
════════════════════════════════════════════
```

---

## STEP 1 Testing Procedure

### Quick Sanity Check (30 seconds)

1. Look at status cards - both should show ✅
2. If both are ✅: Services initialized correctly, proceed to tests
3. If any show ❌: Services failed, see troubleshooting

### Test Sequence (5-10 minutes)

**Order matters** - do tests in this sequence:

#### Test 1: Speech-to-Text (T1.1) - 2 minutes
```
Button: "Test Speech Input"
Do: Click → Wait for "Listening..." → Speak clearly
Say: "I want a red dragon"
Check: Text appears in "Recognized Text" box
Expect: See "Speech recognized: i want a red dragon" in log
```

#### Test 2: TTS Hello (T1.2) - 1 minute
```
Button: "Test TTS: Hello"
Do: Click and listen
Expect: Hear "Hello! This is Crafta speaking!"
Check: No errors in log
```

#### Test 3: TTS Celebration (T1.3) - 1 minute
```
Button: "Test TTS: Celebration"
Do: Click and listen
Expect: Hear "Great job! You are amazing!"
Check: Different voice/tone from Test 2
```

#### Test 4: Complete Loop (T1.4) - 3 minutes ⭐ MOST IMPORTANT
```
Button: "Test Complete Voice Loop"
Do:
  1. Hear: "Hello! I am Crafta. Please say something!"
  2. Say something like: "Make me a blue sword"
  3. Wait for response
Expect: Hear echo: "You said: make me a blue sword"
Check: Full conversation works end-to-end
```

---

## Reading Test Results

### Success Indicators ✅

```
Test log shows:
✅ Speech recognized: [your words]
✅ Text spoken successfully
🟢 Ready for testing
```

### Problem Indicators ⚠️

```
Test log shows:
❌ Speech service not initialized
⚠️ Low confidence result ignored
❌ TTS error
🔴 Service initialization failed
```

---

## Troubleshooting During Testing

### Issue: Services show ❌ on startup

**Cause**: Permissions not granted or audio not available

**Fix**:
1. Check Settings → Apps → Crafta → Permissions
   - Microphone: ON
   - Storage: ON
2. Restart app
3. Grant permissions when prompted

### Issue: Speech not recognized

**Cause**: Microphone issue or low voice input

**Fix**:
1. Speak louder and more clearly
2. Reduce background noise
3. Check microphone is not blocked
4. Test microphone: Voice Recorder app
5. Try again

### Issue: No audio output

**Cause**: Volume muted or speaker issue

**Fix**:
1. Check device volume (not muted)
2. Check headphones connected (if using)
3. Test speaker: Play music
4. Check app audio permissions
5. Restart app

### Issue: App crashes when navigating to /voice-test

**Cause**: Route not registered or service error

**Fix**:
1. Check app is latest build
2. Rebuild: `flutter build apk --release`
3. Reinstall: `adb install -r build/app/outputs/flutter-apk/app-release.apk`
4. Try navigating to main screen first, then to test

---

## Data Collection for Results

After testing, collect this information:

```
═══════════════════════════════════════════════════════════════════
VOICE TEST RESULTS FORM
═══════════════════════════════════════════════════════════════════

Device Information:
  Phone Model: ________________
  Android Version: ____________
  Microphone Model: ___________
  Audio Output: Speaker / Headphones

Test Results:
  T1.1 (Speech-to-Text):   PASS / FAIL
    What you said: _________________________
    What was recognized: ____________________

  T1.2 (TTS Hello):        PASS / FAIL
    Could you hear it? Yes / No
    Voice clarity: Clear / Muffled / Hard to understand

  T1.3 (TTS Celebration):  PASS / FAIL
    Could you hear it? Yes / No
    Different from T1.2? Yes / No

  T1.4 (Complete Loop):    PASS / FAIL
    What you said: _________________________
    What was recognized: ____________________
    Did Crafta echo back? Yes / No

Issues Encountered:
  ❌ _________________________________
  ❌ _________________________________
  ❌ _________________________________

Error Messages (from test log):
  _________________________________________
  _________________________________________

Overall Status:
  ✅ All tests passed - Ready for STEP 2
  ⚠️  Some tests failed - See troubleshooting
  ❌ All tests failed - Major issue

Additional Notes:
  _________________________________________
  _________________________________________

═══════════════════════════════════════════════════════════════════
```

---

## Success Criteria for STEP 1

**STEP 1 Complete when**:
- ✅ T1.1: Speech-to-Text works (text appears)
- ✅ T1.2: TTS works (hear hello message)
- ✅ T1.3: TTS works (hear celebration)
- ✅ T1.4: Complete loop works (speak → listen → echo)

**If all 4 pass**: 🎉 Move to STEP 2: 3D Rendering
**If some fail**: 📋 Debug using troubleshooting guide
**If all fail**: 🔧 Check device setup and permissions

---

## Commands Reference

```bash
# Build APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Reinstall (upgrade existing)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View device logs
adb logcat | grep "VOICE TEST"

# Restart app
adb shell am force-stop com.crafta.app  # adjust package name
adb shell am start com.crafta.app/com.crafta.app.MainActivity

# Check device connected
adb devices

# Remove app
adb uninstall com.crafta.app  # adjust package name
```

---

## Support

**If you get stuck**:
1. Check troubleshooting guide above
2. Screenshot the test log
3. Note device model and Android version
4. Try on different device if available

**For persistent issues**:
- Reinstall app from scratch
- Clear app cache: Settings → Apps → Crafta → Storage → Clear Cache
- Update Flutter: `flutter upgrade`
- Try on different Android device

---

**Ready to Deploy?** Yes! Follow the Quick Start above. 🚀
