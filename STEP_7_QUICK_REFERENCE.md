# STEP 7: Quick Testing Reference

**What**: Device testing for PHASE 0 + PHASE E
**When**: Next session
**Device**: Real Android device (not emulator - needs audio)
**APK**: 67.5MB - build/app/outputs/flutter-apk/app-release.apk

---

## Pre-Testing Checklist

- [ ] Device connected to computer (USB debugging enabled)
- [ ] Microphone works (test in voice recorder app)
- [ ] Speaker/headphones work (test music app)
- [ ] Space available on device (~100MB)
- [ ] Internet connection available (for API calls)
- [ ] Minecraft app installed (optional, but helpful for T4)

---

## Deploy APK

```bash
# From project root:
flutter build apk --release

# Install on device:
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Or manually: Copy APK to phone and tap to install
```

---

## Test Cases

### T1: Basic Approval (5 min)

**Objective**: Verify preview approval works

**Steps**:
1. Open Crafta → /kid-friendly screen
2. Tap large microphone button
3. Speak: "Make me a red dragon"
4. Wait for preview screen to appear
5. Verify: "Here is your red dragon! Do you like it?" (voice)
6. Tap green "Yes! I Love It! 💚" button
7. See world selector dialog
8. Tap "Export & Play" button

**Expected Result**: ✅ Smooth flow with voice feedback

**Logs to Check**:
```
✅ [PHASE E] Preview approval screen initialized
✅ [PHASE E] User approved creature
🚀 [EXPORT] Routing: type=creature
```

---

### T2: Single Modification (8 min)

**Objective**: Verify AI modification works

**Steps**:
1. Repeat T1 steps 1-5
2. Tap orange "Make Changes 🎨" button
3. Hear: "What would you like to change? Tell me!"
4. See dialog with text field
5. Type or say: "Make it bigger and add wings"
6. Tap "Apply Changes"
7. Wait 3-5 seconds for AI to regenerate
8. See new preview appear
9. Verify "Here's the new version! Do you like this better?"
10. Tap "Yes! I Love It!" to complete

**Expected Result**: ✅ New preview shows modified creature

**Logs to Check**:
```
🎨 [PHASE E] User wants to modify creature
🤖 [PHASE E] Calling AI to modify creature
✅ [PHASE E] Creature regenerated successfully
```

---

### T3: Multiple Modifications (10 min)

**Objective**: Verify modification loop

**Steps**:
1. Create creature (T1 steps 1-5)
2. Tap "Make Changes" (T2 steps 3-6)
3. Say: "Make it tiny"
4. New preview appears (attempt 2)
5. Tap "Make Changes" again
6. Say: "Add sparkles"
7. New preview appears (attempt 3)
8. Tap "Yes! I Love It!"
9. Complete export

**Expected Result**: ✅ Multiple attempts tracked and previewed

**Logs to Check**:
```
Attempt 2
Attempt 3
🔄 [PHASE E] Regenerating with modifications
```

---

### T4: Minecraft Export (10 min)

**Objective**: Verify Minecraft integration

**Steps**:
1. Create and approve creature (T1)
2. See world selector: "Create New World" (selected)
3. Tap "Export & Play"
4. Wait 10-15 seconds
5. See: "Launching Minecraft..."
6. Minecraft app should launch

**If Minecraft Launches**:
- ✅ Addon imported successfully
- ✅ Creature appears in creative inventory
- ✅ Can place in world

**If Minecraft Not Installed**:
- See: "⚠️ Minecraft not detected. File saved to Downloads."
- Can tap "More Info" for import instructions
- Check: ~/Downloads/crafta_quick_*.mcpack file exists

**Expected Result**: ✅ File created OR Minecraft launched

**Logs to Check**:
```
📦 Starting quick export with type detection
🚀 [EXPORT] Routing: type=creature
✅ Export complete: /path/to/file.mcpack
✅ [QUICK EXPORT] .mcpack file valid
```

---

## Troubleshooting

### No Voice Heard
**Problem**: Announcements silent
**Solution**:
- Check device volume is not muted
- Check TTS is enabled in system settings
- Try headphones instead of speaker
- Restart app

### Preview Doesn't Update
**Problem**: "Make Changes" doesn't show new preview
**Solution**:
- Check internet (AI needs API access)
- Check API key is set (.env file)
- Wait longer (AI can be slow)
- Check logs for errors

### Modification Dialog Doesn't Appear
**Problem**: Click "Make Changes" but nothing happens
**Solution**:
- Device might have animation delays
- Try waiting 5 seconds
- Restart app
- Check logs for errors

### Minecraft Won't Launch
**Problem**: "Launching Minecraft..." but nothing happens
**Solution**:
- Minecraft not installed (expected)
- Try installing Minecraft
- Check if app was freshly installed
- Look for .mcpack file in Downloads

---

## What to Log

Take notes on:

1. **Voice Quality**
   - Are announcements clear?
   - Good timing between steps?
   - Appropriate volume?

2. **UI/UX**
   - Buttons easy to tap?
   - Text readable?
   - 3D preview works?

3. **AI Modifications**
   - Do changes match request?
   - Regeneration time reasonable?
   - Errors handled gracefully?

4. **Export**
   - File created successfully?
   - Minecraft detected correctly?
   - Launch works?

---

## Success Criteria

**PASS** if:
- ✅ All 4 test cases pass
- ✅ No crashes or errors
- ✅ Voice feedback heard at each step
- ✅ AI modifications working
- ✅ Export/Minecraft integration functional

**FAIL** if:
- ❌ Any test case crashes
- ❌ No voice feedback
- ❌ AI modifications fail
- ❌ Cannot export

---

## Commands Reference

```bash
# Build APK
flutter build apk --release

# Install on device
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View real-time logs
adb logcat | grep -i crafta

# Restart app
adb shell am force-stop com.example.crafta
adb shell am start -n com.example.crafta/com.example.crafta.MainActivity

# Copy file from device
adb pull /sdcard/Download/crafta_quick_*.mcpack ./

# Check package name (if different)
adb shell pm list packages | grep crafta
```

---

## Notes for Next Session

- Document all test results
- Screenshot any errors
- Note any UI improvements needed
- Check voice timing
- Verify AI modifications are reasonable
- Test with different voice inputs

---

**STEP 7 is validation before proceeding to PHASE A (Geometry)**

Good luck! 🎮
