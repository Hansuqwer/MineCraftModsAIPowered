# STEP 7: Full Device Testing Guide

**Phase**: Texture Generation Testing
**Objective**: Verify that green sword and other colored items render correctly on device
**Status**: Ready for execution
**Build**: APK 67.5MB (October 20, 2025)

---

## Pre-Test Checklist

- [ ] Android device connected via USB
- [ ] Device has Minecraft: Bedrock Edition installed
- [ ] USB debugging enabled on device
- [ ] Microphone working and permissions granted to Crafta
- [ ] Recent APK built and available

---

## Step-by-Step Testing Procedure

### Phase 1: Setup & Deployment (5 minutes)

1. **Build and install latest APK**
   ```bash
   flutter build apk --release
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Open app on device**
   - Tap Crafta icon
   - Wait for welcome screen

### Phase 2: Color Texture Testing (10 minutes)

#### Test 2.1: Green Sword (Primary Test)

1. Tap **KID MODE** button
2. Wait for initialization ("Let's create...")
3. Tap the blue microphone button
4. **Speak clearly**: "Make me a green sword"
5. Wait for processing (3-5 seconds)

**Expected Result:**
- ✅ Sword preview appears
- ✅ Sword color is **GREEN** (RGB: 0, 128, 0)
- ✅ Not gray or another color
- ✅ Smooth 3D preview shows

**If FAIL:**
- Check device logs: `flutter logs | grep TEXTURE`
- Should show:
  ```
  ✅ [TEXTURE] Using Flutter Color directly: Color(0xff00ff00)
  🎨 [TEXTURE] Generating simple texture (64x64)
  ✅ [TEXTURE] Generated PNG texture
  ```

---

#### Test 2.2: Red Dragon

1. Tap **"Create Another"** button (or say "again")
2. Tap microphone
3. **Speak**: "Make me a red dragon"

**Expected:**
- ✅ Dragon appears with RED color
- ✅ Red should be bright (RGB: 255, 0, 0)

---

#### Test 2.3: Blue Cat

1. Tap **"Create Another"**
2. Tap microphone
3. **Speak**: "Make me a blue cat"

**Expected:**
- ✅ Cat appears with BLUE color
- ✅ Blue should be bright (RGB: 0, 0, 255)

---

#### Test 2.4: Yellow Car

1. Tap **"Create Another"**
2. Tap microphone
3. **Speak**: "Make me a yellow car"

**Expected:**
- ✅ Car appears with YELLOW color
- ✅ Yellow should be bright (RGB: 255, 255, 0)

---

### Phase 3: Export to Minecraft Testing (15 minutes)

#### Test 3.1: Export Green Sword

1. After creating green sword, tap **"Export & Play"** button
2. Dialog appears: "Where to play?"
3. Select **"Create New World"**
4. Tap **"Export & Play"**

**Expected:**
- ✅ Processing message appears ("Preparing...")
- ✅ Minecraft app launches automatically
- ✅ Minecraft opens with addon imported
- ✅ Sword appears in inventory
- ✅ Sword is GREEN in Minecraft (not gray)

**If Minecraft doesn't launch:**
- Check logs for error messages
- Tap "More Info" in snackbar for manual instructions
- Try selecting **"Use Existing World"** option

---

#### Test 3.2: Export Red Dragon

1. Return to Crafta
2. Create red dragon via voice
3. Tap **"Export & Play"**
4. Select **"Use Existing World"** (adds to previous world)
5. Tap **"Export & Play"**

**Expected:**
- ✅ Minecraft launches
- ✅ Dragon addon imported to existing world
- ✅ Dragon is RED in inventory

---

### Phase 4: Verification & Logging (5 minutes)

#### Collect Debug Information

**While testing, capture logs:**
```bash
flutter logs > texture_test_log.txt 2>&1
```

**Look for specific patterns:**

✅ SUCCESS PATTERNS:
```
✅ [TEXTURE] Using Flutter Color directly
🎨 [TEXTURE] Generating simple texture (64x64)
✅ [TEXTURE] Generated PNG texture: XXX bytes
📦 [QUICK EXPORT] Normalized attributes
✅ [QUICK EXPORT] Export complete
🎮 [LAUNCHER] Minecraft app found
✅ [LAUNCHER] Minecraft launched
```

❌ FAILURE PATTERNS:
```
⚠️ [TEXTURE] Procedural renderer failed
⚠️ [QUICK EXPORT] primaryColor is not string
❌ [LAUNCHER] Error launching Minecraft
```

---

## Test Result Documentation

### Test Matrix

| Test | Input | Expected Color | Result | Notes |
|------|-------|-----------------|--------|-------|
| T7.1 | Green sword | RGB(0,128,0) | ✓ / ✗ | |
| T7.2 | Red dragon | RGB(255,0,0) | ✓ / ✗ | |
| T7.3 | Blue cat | RGB(0,0,255) | ✓ / ✗ | |
| T7.4 | Yellow car | RGB(255,255,0) | ✓ / ✗ | |
| T7.5 | Green sword → Minecraft | GREEN in-game | ✓ / ✗ | |
| T7.6 | Red dragon → Minecraft | RED in-game | ✓ / ✗ | |

---

## Success Criteria

### PASS (All tests must pass)
- [ ] All 4 creatures render with correct colors on device
- [ ] Green sword specifically appears GREEN not gray
- [ ] Export to Minecraft works
- [ ] Colored items appear correctly in Minecraft
- [ ] No crashes or exceptions

### CONDITIONAL PASS
- ✅ Color rendering works, but Minecraft launcher has issues
  - → Export still successful (file saved to Downloads)
  - → Manual import via Minecraft settings works
  - → Not a texture generation failure

---

## Troubleshooting

### Issue: Sword appears GRAY instead of GREEN

**Possible Causes:**
1. Fallback texture used (procedural renderer failed)
   - Check logs for "Procedural renderer failed"
   - Solution: This is OK - fallback texture should still apply color

2. Color not extracted correctly
   - Check logs for "primaryColor is not string"
   - Solution: Already fixed in this commit

3. Image encoding issue
   - Check logs for "Error generating simple texture"
   - Solution: Check if `image` package is working

**Debug Steps:**
```bash
# 1. Check full logs
flutter logs | grep -A5 -B5 TEXTURE

# 2. Look for color values
flutter logs | grep "RGB components"

# 3. Check export normalization
flutter logs | grep "QUICK EXPORT" | head -20
```

---

### Issue: Minecraft Doesn't Launch

**Possible Causes:**
1. Minecraft not installed
   - → Instructions shown in dialog
   - → Can still manually import .mcpack file

2. Intent not supported on device
   - → Try different Android version
   - → Manual import still works

3. File permissions issue
   - → Check if file saved to Downloads
   - → Try manual import from Downloads folder

**Debug Steps:**
```bash
# Check if Minecraft installed
adb shell pm list packages | grep minecraft
```

---

### Issue: Wrong Colors in Minecraft

**Possible Causes:**
1. Texture file wasn't created properly
   - → Check that PNG was generated (1234+ bytes)
   - → Look for "Generated PNG texture: XXX bytes" in logs

2. Minecraft using cached addon
   - → Delete existing addon from Minecraft settings
   - → Re-export and reimport

3. Color space issue
   - → RGB components should be 0-255
   - → Check logs show correct values

---

## Expected Outcomes

### Best Case (All working)
```
✅ Green sword shows green in preview
✅ Exports to Minecraft successfully
✅ Appears green in Minecraft inventory
✅ All other colors work correctly
```

**Next Step**: Proceed to UI REDESIGN phase

---

### Partial Success (Texture works, export has issues)
```
✅ Green sword shows green in preview
✅ Texture generation working
⚠️ Minecraft launcher fails
✅ But .mcpack file saved to Downloads
✅ Manual import to Minecraft works
```

**Next Step**: Debug Minecraft launcher issues, then UI redesign

---

### Failure (Texture not rendering)
```
✅ Sword appears but is GRAY
❌ Not GREEN
❌ Indicates fallback texture or color extraction issue
```

**Next Step**: Review texture_generator.dart logs, check color extraction

---

## Additional Notes

- **Test Duration**: ~30 minutes for full test suite
- **Device Requirements**: Real Android device (emulator has no audio)
- **Minecraft Required**: Bedrock Edition on same device
- **Voice Quality**: Speak clearly, loud enough for device microphone
- **Network**: Not required - all processing is local

---

## Recording Test Results

Please capture:
1. Device model and Android version
2. Screenshots of each colored creature
3. Log file: `flutter logs > test_results_$(date +%Y%m%d_%H%M%S).txt`
4. Any error messages encountered

---

**Test Date**: _______________
**Tester**: _______________
**Device**: _______________
**Android Version**: _______________
**All Tests Passed**: ☐ YES ☐ NO

---

**Ready to test**: ✅ APK 67.5MB built and validated
**Documentation**: ✅ Complete
**Next Phase**: UI REDESIGN (after testing confirms texture fix works)
