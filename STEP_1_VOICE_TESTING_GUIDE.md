# STEP 1: Voice Testing Guide

**Date**: October 20, 2025
**Objective**: Verify Speech-to-Text and Text-to-Speech work correctly
**Location**: Navigate to `/voice-test` screen in app

---

## Pre-Testing Checklist

- [ ] Android device (real device, not emulator - emulators don't support audio well)
- [ ] Microphone working on device
- [ ] Speaker/headphones working
- [ ] APK built from code cleanup version
- [ ] Internet connection (may be needed for some voice APIs)
- [ ] Location: Quiet environment (for speech recognition accuracy)

---

## Testing Infrastructure

We've created a **VoiceTestScreen** specifically for this testing phase. It shows:

1. **Service Status**
   - ✅ Speech-to-Text initialized
   - ✅ Text-to-Speech initialized

2. **Individual Tests**
   - Test Speech Input (listen for 15 seconds)
   - Test TTS: "Hello" message
   - Test TTS: "Celebration" message

3. **Integration Test**
   - Complete Voice Loop (speak → AI listens → AI responds → AI speaks back)

4. **Live Test Log**
   - Real-time output of what's happening
   - Shows errors and successes

---

## How to Access

### Option A: Direct Route
If you have debug mode enabled, you can navigate directly:
```
App → Settings → (URL bar or menu) → /voice-test
```

### Option B: Via Routes
In the app code, the route is registered as:
```dart
'/voice-test': (context) => const VoiceTestScreen(),
```

### Option C: From Terminal (if running via Flutter)
```bash
flutter run -d <device-id>
# Then press 't' in terminal and type: /voice-test
```

---

## Test Sequence: T1.1 - T1.4

### T1.1: Speech-to-Text Test ⭐ START HERE

**What to do**:
1. Open `/voice-test` screen
2. Look at the status cards at top
   - Should see ✅ for "Speech-to-Text"
   - Should see ✅ for "Text-to-Speech"
3. Click button **"Test Speech Input"**
4. When you see "Listening...", speak clearly:
   ```
   "Hello Crafta, I want to create a red dragon"
   ```
5. Wait for result

**What to expect**:
- Button changes to "Listening..."
- After ~2 seconds, see "Recognized Text:" section
- Should display what you said
- Test log should show:
  ```
  🎤 VOICE TEST: Starting speech recognition...
  ✅ Speech recognized: hello crafta i want to create a red dragon
  ```

**Success Criteria**:
- ✅ Speech recognized AND displayed
- ✅ Confidence > 30%
- ✅ Text appears in "Recognized Text" box
- ✅ No errors in log

**If it fails**:
- Check microphone permission in Settings
- Try in quieter environment
- Speak more clearly and slowly
- Check if SpeechService initialized

---

### T1.2: Text-to-Speech Test

**What to do**:
1. On same screen, click **"Test TTS: Hello"** button
2. Listen for audio output
3. You should hear Crafta say: "Hello! This is Crafta speaking!"

**What to expect**:
- Hear a warm, friendly voice
- Test log shows:
  ```
  🔊 Speaking: "Hello! This is Crafta speaking!"
  ✅ Text spoken successfully
  ```

**Success Criteria**:
- ✅ Hear voice output
- ✅ Voice is clear and friendly
- ✅ No error messages in log

**If it fails**:
- Check device volume (not muted)
- Check speaker/headphones working
- Tap "Test TTS: Celebration" to try another message

---

### T1.3: Test Celebration Message

**What to do**:
1. Click **"Test TTS: Celebration"** button
2. Listen for celebratory voice message

**What to expect**:
- Hear: "Great job! You are amazing!"
- Different tone/inflection than regular message
- Log shows success

**Success Criteria**:
- ✅ Hear the message
- ✅ Different personality from T1.2

---

### T1.4: Complete Voice Loop Test ⭐ MOST IMPORTANT

**What to do**:
1. Make sure both services initialized (check status cards)
2. Click **"Test Complete Voice Loop"** button
3. Listen - Crafta should say: "Hello! I am Crafta. Please say something!"
4. When you hear the prompt, say something natural:
   ```
   "I want a blue sword"
   OR
   "Make me a flying horse"
   OR
   "Create a rainbow cow"
   ```
5. Wait for Crafta to echo back what you said

**What to expect**:
- Crafta greets you with voice
- Listens to your speech (showing "Listening...")
- Displays your recognized text
- Crafta speaks back: "You said: [your words]"

**Test Log should show**:
```
=== TESTING COMPLETE VOICE LOOP ===
Step 1: Speaking test message
🔊 Speaking: "Hello! I am Crafta. Please say something!"
✅ Text spoken successfully

Step 2: Listening for your response
🎤 Starting speech recognition...

(wait ~15 seconds)

✅ Speech recognized: i want a blue sword

Step 3: Echoing what you said
🔊 Speaking: "You said: i want a blue sword"
✅ Text spoken successfully
```

**Success Criteria**:
- ✅ Crafta greets you with voice
- ✅ Listens and captures your speech
- ✅ Displays recognized text
- ✅ Crafta speaks back what you said
- ✅ No errors throughout

---

## Test Log Interpretation

### Good Log Examples

✅ Speech successful:
```
✅ Speech recognized: hello crafta
```

✅ TTS successful:
```
🔊 Speaking: "Hello! This is Crafta speaking!"
✅ Text spoken successfully
```

✅ Services initialized:
```
✅ Both services ready!
Initializing Speech-to-Text service...
Speech-to-Text: ✅ Ready
Text-to-Speech: ✅ Ready
```

### Problem Log Examples

❌ Speech not recognized:
```
❌ Speech error: No speech input detected
```

❌ Low confidence:
```
Low confidence result ignored: 0.15
```

❌ Service not initialized:
```
❌ Speech service not initialized
Speech-to-Text: ❌ Failed
```

---

## Troubleshooting Guide

### Issue: "Speech service not initialized"
**Cause**: SpeechService failed to initialize
**Solution**:
1. Check microphone permissions in device Settings
2. Restart app
3. Try on real device (not emulator)
4. Check if `speech_to_text` plugin is properly installed

### Issue: "Listening..." but nothing happens
**Cause**: Speech recognition timeout or no audio detected
**Solution**:
1. Speak loudly and clearly
2. Try in quieter environment
3. Check microphone is not muted
4. Wait full 15 seconds

### Issue: Hear no audio output
**Cause**: TTS not working
**Solution**:
1. Check device volume (not muted)
2. Check speaker/headphone connected
3. Verify TTS permissions
4. Restart app

### Issue: "High confidence result ignored"
**Cause**: Voice detected but below 30% confidence threshold
**Solution**:
1. Speak more clearly
2. Reduce background noise
3. Speak closer to microphone
4. Try slower, more deliberate speech

### Issue: Numbers or symbols in recognized text
**Cause**: Speech recognition misheard words
**Solution**:
- This is normal for similar-sounding words
- Try again or enunciate more clearly

---

## Success Metrics

For STEP 1 to be considered **COMPLETE**:

| Test | Requirement | Status |
|------|-------------|--------|
| **T1.1** | Speech-to-text recognizes 3+ sentences | ⏳ Pending |
| **T1.2** | TTS outputs "Hello" message clearly | ⏳ Pending |
| **T1.3** | TTS outputs celebration message | ⏳ Pending |
| **T1.4** | Complete loop works: speak → listen → echo | ⏳ Pending |
| **Overall** | All 4 tests pass with no blocking errors | ⏳ Pending |

---

## How to Report Results

After running tests, note:
1. Which tests passed ✅
2. Which tests failed ❌
3. Any error messages
4. Device details (Android version, device name)
5. Screenshots of test log if possible

Example report:
```
TEST RESULTS:
✅ T1.1: Speech recognized "hello crafta"
✅ T1.2: Heard "Hello! This is Crafta speaking!"
⚠️ T1.3: Audio was quiet but understandable
✅ T1.4: Complete loop worked end-to-end

Issues: None blocking
Device: Samsung Galaxy A12, Android 11
Recommendation: Ready for STEP 2
```

---

## Important Notes

⚠️ **Device, not Emulator**: Flutter emulators often don't support audio APIs well. Use a real Android device.

⚠️ **Permissions**: App may request microphone permission on first run. Grant it.

⚠️ **Network**: Some voice APIs need internet connection. Ensure device is connected.

⚠️ **Timing**: Allow 15-20 seconds between tests for services to process.

⚠️ **Quiet Environment**: Speech recognition works best with minimal background noise.

---

## Next Steps After STEP 1

**If all tests pass** ✅:
- Continue to STEP 2: 3D Rendering testing
- Voice system is working correctly

**If some tests fail** ⚠️:
- Document which tests failed
- Review troubleshooting guide
- Retry with adjustments
- Report issues for debugging

**If all tests fail** ❌:
- Check device setup (microphone, speaker)
- Verify permissions granted
- Check internet connection
- Try restarting app
- Contact support with test logs

---

**Testing Guide Created**: October 20, 2025
**Ready to Deploy**: Yes ✅
