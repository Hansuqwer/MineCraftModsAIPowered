# User Testing Issues - October 21, 2025

**Tester**: User (Rickard)
**APK**: Crafta_Latest_20251021.apk (67.5MB)
**Date**: October 21, 2025

---

## Issues Found

### 🔴 CRITICAL ISSUES

#### 1. Voice Setup Autocompletes Itself
**Problem**: When in voice calibration screen, user is told to say "Hello Crafta", but the AI voice completes the step automatically without user input.

**Root Cause**: Likely TTS is triggering the speech recognition service
- TTS says "Say Hello Crafta"
- Speech recognition hears the TTS output
- System thinks user completed the step

**Impact**: Voice calibration cannot be completed properly

**Fix Required**:
- Disable speech recognition while TTS is speaking
- Add delay between TTS completion and speech recognition start
- Mute microphone during TTS playback

---

#### 2. App Running in Offline Mode (Not Using API Keys)
**Problem**: Enhanced creator shows "AI is working offline right now"

**Root Cause**: API keys not configured or not being loaded
- `.env` file missing or not in correct location
- API keys not set
- EnhancedAIService falling back to offline cache

**Impact**:
- Poor quality creatures (using local cache instead of GPT-4)
- Limited variety
- No true AI understanding

**Fix Required**:
- First-run setup wizard to configure API keys
- Check if API keys exist on app launch
- Prompt user to enter OpenAI API key
- Validate key before proceeding
- Save to secure storage

---

#### 3. Export to Minecraft Fails
**Problem**: Export fails with "Minecraft not detected" then tries to save to `/sdcard/downloads` but fails

**Symptoms**:
- "Preparing creation for Minecraft" loading message
- Then: "Minecraft not detected"
- Attempts to save to `/sdcard/downloads`
- Fails (likely permission issue)

**Root Cause**:
- Storage permission not requested
- Export path `/sdcard/downloads` incorrect (should be `/sdcard/Download` on many devices)
- No fallback to user-accessible directory
- MinecraftExportService not handling errors gracefully

**Impact**: Cannot export creatures at all - feature completely broken

**Fix Required**:
- Request storage permissions on first export
- Use proper Android Download directory (via path_provider)
- Show success message with file location
- Add "Share file" button as fallback
- Better error messages

---

### 🟡 HIGH PRIORITY ISSUES

#### 4. Preview Shows Wrong Graphics
**Problem**:
- Initial preview shows just a "happy face that changes color"
- After "make changes", preview shows better dragon-like creature

**Root Cause**:
- Initial preview using placeholder/fallback renderer
- CreaturePreview widget not using proper attributes
- After AI regeneration, attributes are better formed
- Possible: offline mode returns incomplete creature data

**Impact**: User doesn't see accurate preview of their creation

**Fix Required**:
- Fix CreaturePreview widget to render proper creatures
- Use procedural generation based on attributes
- Test with both online and offline modes
- Ensure consistent rendering

---

#### 5. Creation History Not Updating
**Problem**: Creation history only shows items from "a couple of days ago", doesn't update with new creations

**Root Cause**:
- LocalStorageService not being called after creature creation
- New creatures created but not persisted
- History screen not refreshing
- Possible: creatures saved but screen not reloading data

**Impact**: Users cannot see or re-export their recent creations

**Fix Required**:
- Call `LocalStorageService.saveCreature()` after creature generation
- Refresh history screen when navigating back
- Add created_at timestamp to creatures
- Sort by most recent first

---

### 🟢 MEDIUM PRIORITY ISSUES

#### 6. No First-Run Setup Experience
**Problem**: App doesn't have onboarding to configure API keys when first launched

**Impact**: App runs in offline mode by default, poor experience

**Fix Required**:
- Create FirstRunSetupScreen
- Steps:
  1. Welcome message
  2. API key configuration (optional but recommended)
  3. Voice calibration
  4. Quick tutorial
  5. Language selection
- Show only on first launch
- Store completion flag in SharedPreferences

---

#### 7. UI Cleanup Needed
**Problem**: Home screen has unnecessary buttons:
- "Choose what to create" - should be removed
- "Quick start creature" - should be removed
- "Kid mode" exists but name needs to change

**User Request**:
> "The buttons choose what to create and quick start creature. They shouldn't exist, only kid mode but that name has to change."

**Fix Required**:
- Remove "Choose what to create" button
- Remove "Quick start creature" button
- Keep kid mode as primary/only mode
- Rename "Kid mode" to something better:
  - Options: "Start Creating", "Create Now", "Let's Go", "Begin", "Create"
- Simplify home screen to single entry point

---

## Summary by Category

### Voice/Audio Issues
1. ✅ Voice setup autocompletes itself
2. ✅ Need TTS/STT coordination

### AI/Backend Issues
3. ✅ App running offline (no API keys)
4. ✅ Need first-run setup
5. ✅ Poor quality creatures in offline mode

### Export Issues
6. ✅ Minecraft export fails completely
7. ✅ Storage permissions
8. ✅ File path issues

### UI/UX Issues
9. ✅ Preview shows wrong graphics
10. ✅ Creation history not updating
11. ✅ Too many buttons on home screen
12. ✅ "Kid mode" naming

### Persistence Issues
13. ✅ New creatures not being saved
14. ✅ History screen not refreshing

---

## Testing Environment

**Device**: Android phone (real device)
**APK Size**: 67.5MB
**Build Date**: October 21, 2025
**API Mode**: Offline (no keys configured)

---

## Next Steps

See: `PHASE_LIST_FIX_ROADMAP.md` for prioritized fix plan
