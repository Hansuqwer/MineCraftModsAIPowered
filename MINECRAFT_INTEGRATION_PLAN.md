# Minecraft Integration Plan - Direct Export & Launch

**Date**: October 20, 2025
**Goal**: Create seamless voice-to-Minecraft flow
**Status**: Implementation starting (Option A - Full)
**Estimated Time**: 4-5 hours

---

## Current Problem

**User Flow Now** (BROKEN):
```
Create sword by voice ✅
    ↓
Click Export button on preview
    ↓
Nothing happens ❌
```

**What User Wants**:
```
Create sword by voice ✅
    ↓
Click "EXPORT & PLAY" button
    ↓
Choose world (New/Existing)
    ↓
Minecraft opens with sword ready ✅
```

---

## Issues Found

### Issue 1: Export Button Chain Too Complex
- Preview screen → Complete screen → Export screen (3 steps!)
- User expects 1 click to export
- Navigation might be failing silently
- **File**: `lib/screens/creature_preview_screen.dart:302`

### Issue 2: No Texture Applied
- Sword appears but no green color
- Texture generator not working properly
- Model is basic 3D geometry only
- **File**: `lib/services/minecraft/texture_generator.dart`

### Issue 3: No Minecraft Launcher
- Export creates .mcpack file
- But can't launch Minecraft from app
- User must manually open Minecraft
- **File**: Needs to be created: `lib/services/minecraft_launcher_service.dart`

---

## Solution: Direct Export with Minecraft Launcher

### PART 1: Add "QUICK EXPORT" Button (to preview screen)

**New Button**: "⚡ EXPORT & PLAY"
- One click export
- Shows world selector dialog
- Launches Minecraft app
- Sword ready to play

**Location**: On creature preview screen, next to existing "Export" button
**File**: `lib/screens/creature_preview_screen.dart`

### PART 2: Fix Texture Generation

**Current Issue**: Color not applied to model

**Fix**:
- Check texture_generator.dart
- Ensure green color (from creatureAttributes.primaryColor) is applied
- Generate proper PNG texture file with creature color

**File**: `lib/services/minecraft/texture_generator.dart`

### PART 3: Implement Minecraft Launcher

**Technology**: Android Intents

**Flow**:
1. Generate .mcpack file
2. Save to Downloads folder
3. Send intent to Minecraft app
4. Minecraft handles import

**Code Pattern**:
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> launchMinecraftWithAddon(String mcpackPath) async {
  // Android intent to open Minecraft with addon
  final Uri uri = Uri(
    scheme: 'content',
    host: 'file',
    path: mcpackPath,
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
```

---

## Implementation Steps (OPTION A - FULL)

### Step 1: Add Quick Export Button (30 min)
**File**: `lib/screens/creature_preview_screen.dart`
**What**: Add new button after existing "Export" button
**Location**: Line ~300-320 where Export button is
**Button name**: "Export & Play"
**Action**: Opens world selector dialog → exports → launches Minecraft

### Step 2: Create Quick Export Service (1 hour)
**File**: Create `lib/services/quick_minecraft_export_service.dart`
**What**:
- Simplifies export flow (no multiple screens)
- Generates addon directly from creatureAttributes
- Saves to standard Downloads folder
- Returns file path
- Key methods:
  - `quickExportCreature(creatureAttributes)` → returns mcpackPath
  - Handles all JSON generation
  - Creates proper texture with color

### Step 3: Add World Selector Dialog (30 min)
**File**: `lib/screens/creature_preview_screen.dart`
**What**: New dialog when "Export & Play" clicked
**UI**:
```
┌─────────────────────────────────┐
│   Where to play?                │
├─────────────────────────────────┤
│  ◉ Create New World             │
│  ○ Use Existing World           │
│                                 │
│     [CANCEL]    [EXPORT & PLAY] │
└─────────────────────────────────┘
```

### Step 4: Implement Minecraft Launcher Service (1 hour)
**File**: Create `lib/services/minecraft_launcher_service.dart`
**What**:
- Sends Android intent to Minecraft
- Opens Minecraft app
- Passes .mcpack file
- Methods:
  - `launchMinecraftWithAddon(mcpackPath, worldType)`
  - Handles if Minecraft not installed

### Step 5: Fix Texture Generation (1-2 hours)
**File**: `lib/services/minecraft/texture_generator.dart`
**What**: Debug and fix texture color application
**Problem**: Green color from creatureAttributes.primaryColor not being applied to texture PNG
**Solution**:
- Check if color conversion working (Flutter Color → RGB)
- Ensure PNG generator uses the color
- Test with sample creature (should see green sword, not gray)

### Step 6: Update pubspec.yaml (15 min)
**Add dependency**: `url_launcher` (for Android intents)
```yaml
dependencies:
  url_launcher: ^6.1.0
```

### Step 7: Test Full Flow (1 hour)
**Steps**:
1. Deploy new APK
2. Create item by voice: "green sword"
3. Click "Export & Play" button
4. Select "Create New World"
5. Verify Minecraft launches
6. Verify sword appears with green color
7. Test "Use Existing World" option
8. Verify both work

---

## Files to Create/Modify

| File | Action | Time | Priority |
|------|--------|------|----------|
| `lib/services/quick_minecraft_export_service.dart` | **CREATE** | 1 hr | HIGH |
| `lib/services/minecraft_launcher_service.dart` | **CREATE** | 1 hr | HIGH |
| `lib/screens/creature_preview_screen.dart` | **MODIFY** | 1 hr | HIGH |
| `lib/services/minecraft/texture_generator.dart` | **DEBUG/FIX** | 1-2 hrs | HIGH |
| `pubspec.yaml` | **MODIFY** | 15 min | MEDIUM |

---

## Key Implementation Details

### quick_minecraft_export_service.dart Structure
```dart
class QuickMinecraftExportService {
  static Future<String> quickExportCreature({
    required Map<String, dynamic> creatureAttributes,
    required String creatureName,
  }) async {
    // 1. Generate addon package
    // 2. Apply texture with color
    // 3. Save as .mcpack
    // 4. Return file path
  }

  static Future<void> saveAsMcpack(AddonPackage addon) async {
    // Save to Downloads folder
  }
}
```

### minecraft_launcher_service.dart Structure
```dart
class MinecraftLauncherService {
  static Future<bool> isMinecraftInstalled() async {
    // Check if Minecraft app exists
  }

  static Future<void> launchMinecraftWithAddon(
    String mcpackPath,
    String worldType, // 'new' or 'existing'
  ) async {
    // Send Android intent to Minecraft
  }
}
```

### Texture Fix Checklist
- [ ] Verify color conversion: Flutter Color → RGB bytes
- [ ] Check PNG generator receives correct color
- [ ] Test with red, green, blue colors
- [ ] Ensure alpha channel correct
- [ ] Verify texture applies to all mesh surfaces

---

## Success Criteria

✅ User can export by clicking one button ("Export & Play")
✅ World selector dialog appears
✅ Minecraft app launches (if installed)
✅ .mcpack file automatically imported
✅ Sword appears in Minecraft ready to play
✅ Texture is green (not gray)
✅ Works for all creature types
✅ Error handling if Minecraft not installed

---

## If Running Out of Tokens

**Next AI Should**:
1. Read this document
2. Check which steps completed (git log)
3. Continue from next incomplete step
4. Test each step before moving to next
5. Commit progress frequently

**Priority Order**:
1. Steps 1-4 (UI/Export) - Core functionality
2. Step 5 (Texture) - Visual polish
3. Step 6-7 (Dependencies/Testing) - Final

---

## Git Commit Messages Template

```bash
# After Step 1
git add ... && git commit -m "feat: Add 'Export & Play' button to preview screen

Quick export for direct Minecraft launch"

# After Step 2
git add ... && git commit -m "feat: Implement quick export service

Simplified export flow bypassing multiple screens"

# After Step 3
git add ... && git commit -m "feat: Add world selector dialog for Minecraft export

Choose between new world or existing world"

# After Step 4
git add ... && git commit -m "feat: Implement Minecraft app launcher

Can now open Minecraft directly from Crafta"

# After Step 5
git add ... && git commit -m "fix: Fix texture generation for creature colors

Sword now appears green instead of gray"
```

---

## Testing Commands

```bash
# Build after each step
flutter build apk --release

# Install on device
adb install -r build/app/outputs/flutter-apk/app-release.apk

# View logs for errors
flutter logs | grep "MINECRAFT\|EXPORT\|TEXTURE"
```

---

**Document Status**: Complete and ready for implementation
**Next Action**: START STEP 1 (Add Export & Play button)
**Estimated Completion**: 4-5 hours of work
