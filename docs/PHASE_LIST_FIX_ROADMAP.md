# Phase List: Fix Roadmap After User Testing

**Created**: October 21, 2025
**Based On**: USER_TESTING_ISSUES_OCT21.md
**Goal**: Get all features working properly

---

## 🎯 Priority Overview

| Phase | Priority | Time | Status |
|-------|----------|------|--------|
| PHASE F | 🔴 CRITICAL | 2-3 hours | ⏳ Pending |
| PHASE G | 🔴 CRITICAL | 2-3 hours | ⏳ Pending |
| PHASE H | 🟡 HIGH | 1-2 hours | ⏳ Pending |
| PHASE I | 🟡 HIGH | 1-2 hours | ⏳ Pending |
| PHASE J | 🟢 MEDIUM | 30 min | ⏳ Pending |

**Total Estimated Time**: 7-10 hours

---

## PHASE F: First-Run Setup & API Configuration 🔴

**Priority**: CRITICAL
**Time**: 2-3 hours
**Fixes Issues**: #2 (Offline mode), #6 (No onboarding)

### Problem
App runs in offline mode because API keys aren't configured. Users don't know how to set them up.

### Solution
Create comprehensive first-run setup wizard

### Implementation Steps

#### F.1: Create FirstRunSetupScreen
**File**: `lib/screens/first_run_setup_screen.dart`

**Features**:
- Welcome screen with app explanation
- API key input screen (with "Skip" option)
- Voice calibration
- Language selection
- Tutorial completion
- Save completion flag to SharedPreferences

**UI Flow**:
```
1. Welcome Screen
   "Welcome to Crafta! Let's set things up..."
   [Next]

2. API Configuration Screen
   "For best results, add your OpenAI API key"
   [Text field for API key]
   [Test Key] [Skip] [Next]

3. Voice Calibration
   "Let's test your voice!"
   [Start Test] [Skip]

4. Language Selection
   "Which language do you prefer?"
   [English] [Swedish]

5. Quick Tutorial
   "Here's how to create creatures..."
   [3-4 example screens]
   [Done]
```

#### F.2: Update main.dart
**File**: `lib/main.dart`

**Changes**:
```dart
// Check if first run
final prefs = await SharedPreferences.getInstance();
final hasCompletedSetup = prefs.getBool('has_completed_setup') ?? false;

// Set initial route
initialRoute: hasCompletedSetup ? '/welcome' : '/first-run-setup',

// Add route
'/first-run-setup': (context) => const FirstRunSetupScreen(),
```

#### F.3: Secure API Key Storage
**Service**: `lib/services/api_key_service.dart` (NEW)

**Methods**:
```dart
class ApiKeyService {
  // Save API key to secure storage
  Future<void> saveApiKey(String key);

  // Load API key from secure storage
  Future<String?> getApiKey();

  // Test if API key is valid
  Future<bool> validateApiKey(String key);

  // Remove API key
  Future<void> removeApiKey();

  // Check if key exists
  Future<bool> hasApiKey();
}
```

**Uses**: `flutter_secure_storage` package (already in pubspec.yaml)

#### F.4: Update EnhancedAIService
**File**: `lib/services/enhanced_ai_service.dart`

**Changes**:
```dart
// In initialize():
// 1. Check ApiKeyService first
final apiKey = await ApiKeyService().getApiKey();

// 2. If key exists, use it
if (apiKey != null && apiKey.isNotEmpty) {
  _apiKey = apiKey;
  _isOnline = true;
} else {
  // 3. Fall back to .env
  _apiKey = dotenv.env['OPENAI_API_KEY'];
  _isOnline = (_apiKey != null && _apiKey.isNotEmpty);
}
```

#### F.5: Add Online/Offline Indicator
**Widget**: `lib/widgets/api_status_indicator.dart` (NEW)

**Display**:
- 🟢 Green: "Connected to AI"
- 🟡 Yellow: "Limited Mode (No API Key)"
- 🔴 Red: "No Internet Connection"

**Placement**: Top-right corner of main screens

### Files to Create
- `lib/screens/first_run_setup_screen.dart` (~400 lines)
- `lib/services/api_key_service.dart` (~150 lines)
- `lib/widgets/api_status_indicator.dart` (~100 lines)

### Files to Modify
- `lib/main.dart` (+20 lines)
- `lib/services/enhanced_ai_service.dart` (+30 lines)

### Testing
- [ ] First launch shows setup wizard
- [ ] Can enter API key and it persists
- [ ] Can skip API key setup
- [ ] API key validation works
- [ ] App uses saved API key on restart
- [ ] Online indicator shows correct status

---

## PHASE G: Fix Minecraft Export 🔴

**Priority**: CRITICAL
**Time**: 2-3 hours
**Fixes Issues**: #3 (Export fails)

### Problem
Export completely fails:
- "Minecraft not detected" error
- Tries to save to `/sdcard/downloads` but fails
- Likely permission issues
- No user feedback on success/failure

### Solution
Fix export path, add permissions, improve error handling

### Implementation Steps

#### G.1: Request Storage Permissions
**File**: `android/app/src/main/AndroidManifest.xml`

**Add Permissions**:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
                 tools:ignore="ScopedStorage" />
```

#### G.2: Add Permission Handler
**Package**: Add `permission_handler` to pubspec.yaml

```yaml
dependencies:
  permission_handler: ^11.0.0
```

#### G.3: Create PermissionService
**File**: `lib/services/permission_service.dart` (NEW)

**Methods**:
```dart
class PermissionService {
  // Request storage permission
  Future<bool> requestStoragePermission();

  // Check if granted
  Future<bool> hasStoragePermission();

  // Open app settings
  Future<void> openAppSettings();
}
```

#### G.4: Fix Export Path
**File**: `lib/services/minecraft/minecraft_export_service.dart`

**Changes**:
```dart
// OLD (broken):
final exportPath = '/sdcard/downloads/crafta_${timestamp}.mcpack';

// NEW (fixed):
import 'package:path_provider/path_provider.dart';

Future<String> _getExportPath(String filename) async {
  if (Platform.isAndroid) {
    // Try external storage directory first
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      return '${directory.path}/$filename';
    }

    // Fallback to downloads (requires permission)
    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (await downloadsDir.exists()) {
      return '${downloadsDir.path}/$filename';
    }
  }

  // Final fallback
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$filename';
}
```

#### G.5: Add Export Success UI
**File**: `lib/screens/creature_preview_approval_screen.dart`

**Add Dialog After Export**:
```dart
void _showExportSuccessDialog(String filePath) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('✅ Export Complete!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your creature has been saved!'),
          SizedBox(height: 16),
          Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
          SelectableText(filePath, style: TextStyle(fontSize: 12)),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.share),
            label: Text('Share File'),
            onPressed: () => _shareFile(filePath),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Open in Minecraft'),
          onPressed: () => _openInMinecraft(filePath),
        ),
        TextButton(
          child: Text('Done'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
```

#### G.6: Add File Sharing
**Package**: Already have `share_plus` in pubspec.yaml

**Implementation**:
```dart
Future<void> _shareFile(String filePath) async {
  await Share.shareXFiles([XFile(filePath)]);
}
```

#### G.7: Improve Minecraft Detection
**File**: `lib/services/minecraft_launcher_service.dart`

**Better Detection Logic**:
```dart
Future<bool> isMinecraftInstalled() async {
  if (Platform.isAndroid) {
    try {
      // Try multiple package names
      final packages = [
        'com.mojang.minecraftpe',      // Main
        'com.mojang.minecraftpe.beta',  // Beta
        'com.mojang.minecraftpe.trial', // Trial
      ];

      for (final package in packages) {
        final result = await Process.run('pm', ['list', 'packages', package]);
        if (result.stdout.toString().contains(package)) {
          return true;
        }
      }
    } catch (e) {
      print('Error checking Minecraft: $e');
    }
  }
  return false;
}
```

### Files to Create
- `lib/services/permission_service.dart` (~100 lines)

### Files to Modify
- `android/app/src/main/AndroidManifest.xml` (+5 lines)
- `pubspec.yaml` (+1 dependency)
- `lib/services/minecraft/minecraft_export_service.dart` (+50 lines)
- `lib/services/minecraft_launcher_service.dart` (+30 lines)
- `lib/screens/creature_preview_approval_screen.dart` (+80 lines)

### Testing
- [ ] Storage permission requested before export
- [ ] Export succeeds and creates file
- [ ] Success dialog shows file path
- [ ] Can share exported file
- [ ] File opens in Minecraft if installed
- [ ] Graceful handling if Minecraft not installed

---

## PHASE H: Fix Creation History Persistence 🟡

**Priority**: HIGH
**Time**: 1-2 hours
**Fixes Issues**: #5 (History not updating)

### Problem
Creation history shows old items, doesn't update with new creations

### Solution
Integrate LocalStorageService into creation flow

### Implementation Steps

#### H.1: Save Creature After Creation
**File**: `lib/screens/kid_friendly_screen.dart`

**After Line ~117** (after AI parsing):
```dart
// Existing code:
final enhancedAttributes = await KidVoiceService.parseKidVoiceWithAI(text);

// ADD THIS:
if (enhancedAttributes != null) {
  // Save to local storage
  await LocalStorageService().saveCreature({
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'name': enhancedAttributes['name'] ?? 'Unnamed Creature',
    'created_at': DateTime.now().toIso8601String(),
    'attributes': enhancedAttributes,
  });
}
```

#### H.2: Save After Modifications
**File**: `lib/screens/creature_preview_approval_screen.dart`

**After regeneration**:
```dart
// After _modifyCreatureWithAI() succeeds
await LocalStorageService().saveCreature({
  'id': widget.creatureAttributes['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
  'name': widget.creatureAttributes['name'] ?? 'Modified Creature',
  'modified_at': DateTime.now().toIso8601String(),
  'attributes': widget.creatureAttributes,
  'generation_attempt': _generationAttempt,
});
```

#### H.3: Refresh History Screen
**File**: `lib/screens/creature_history_screen.dart` (if exists)

**Add refresh on navigate**:
```dart
@override
void initState() {
  super.initState();
  _loadCreatures();
}

Future<void> _loadCreatures() async {
  final creatures = await LocalStorageService().loadCreatures();
  setState(() {
    _creatures = creatures;
  });
}

// Pull-to-refresh
RefreshIndicator(
  onRefresh: _loadCreatures,
  child: ListView.builder(...),
)
```

#### H.4: Sort by Most Recent
**File**: `lib/services/local_storage_service.dart`

**Update loadCreatures()**:
```dart
Future<List<Map<String, dynamic>>> loadCreatures() async {
  // ... existing load logic ...

  // Sort by created_at (most recent first)
  creatures.sort((a, b) {
    final aTime = DateTime.parse(a['created_at'] ?? '1970-01-01');
    final bTime = DateTime.parse(b['created_at'] ?? '1970-01-01');
    return bTime.compareTo(aTime); // Descending
  });

  return creatures;
}
```

### Files to Modify
- `lib/screens/kid_friendly_screen.dart` (+10 lines)
- `lib/screens/creature_preview_approval_screen.dart` (+15 lines)
- `lib/screens/creature_history_screen.dart` (+20 lines)
- `lib/services/local_storage_service.dart` (+10 lines)

### Testing
- [ ] New creatures appear in history immediately
- [ ] Modified creatures update in history
- [ ] History sorted by most recent first
- [ ] Pull-to-refresh works
- [ ] Timestamps accurate

---

## PHASE I: Fix Preview Rendering 🟡

**Priority**: HIGH
**Time**: 1-2 hours
**Fixes Issues**: #4 (Preview shows wrong graphics)

### Problem
Initial preview shows "happy face that changes color" instead of proper creature. After modifications, it looks better.

### Solution
Fix CreaturePreview widget to use procedural rendering properly

### Implementation Steps

#### I.1: Debug Current Preview
**File**: `lib/widgets/creature_preview.dart` (or wherever preview is)

**Check**:
- Is it receiving correct attributes?
- Is ProceduralCreatureRenderer being used?
- Are colors being applied?
- Are shapes rendering correctly?

#### I.2: Improve ProceduralCreatureRenderer
**File**: `lib/widgets/procedural_creature_renderer.dart`

**Enhancements**:
```dart
// Add more body shapes based on creature type
void _drawCreatureBody(Canvas canvas, Size size) {
  final baseType = attributes['baseType'] ?? 'creature';

  switch (baseType.toLowerCase()) {
    case 'dragon':
      _drawDragonBody(canvas, size);
      break;
    case 'cat':
    case 'tiger':
    case 'lion':
      _drawFelineBody(canvas, size);
      break;
    case 'bird':
      _drawBirdBody(canvas, size);
      break;
    default:
      _drawGenericBody(canvas, size);
  }
}

void _drawDragonBody(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = _getPrimaryColor()
    ..style = PaintingStyle.fill;

  // Body (oval)
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.4,
      height: size.height * 0.5,
    ),
    paint,
  );

  // Head (circle)
  canvas.drawCircle(
    Offset(size.width * 0.5, size.height * 0.3),
    size.width * 0.15,
    paint,
  );

  // Wings (if flying ability)
  if (_hasAbility('flying')) {
    _drawWings(canvas, size);
  }

  // Tail
  _drawTail(canvas, size);

  // Legs
  _drawLegs(canvas, size, count: 4);
}
```

#### I.3: Add More Visual Details
**Add Methods**:
```dart
void _drawWings(Canvas canvas, Size size);
void _drawTail(Canvas canvas, Size size);
void _drawLegs(Canvas canvas, Size size, {int count = 4});
void _drawHorns(Canvas canvas, Size size);
void _drawScales(Canvas canvas, Size size);
void _drawFur(Canvas canvas, Size size);
```

#### I.4: Test with Online vs Offline
**Compare**:
- Offline creature attributes structure
- Online (API) creature attributes structure
- Ensure both render properly

### Files to Modify
- `lib/widgets/procedural_creature_renderer.dart` (+200 lines)
- `lib/widgets/creature_preview.dart` (+20 lines)

### Testing
- [ ] Dragon looks like a dragon
- [ ] Cat looks like a cat
- [ ] Birds have wings
- [ ] Colors apply correctly
- [ ] Size variations work
- [ ] Works in both online/offline modes

---

## PHASE J: Voice Calibration Fix + UI Cleanup 🟢

**Priority**: MEDIUM
**Time**: 30 minutes
**Fixes Issues**: #1 (Voice autocomplete), #7 (UI cleanup)

### Problem 1: Voice Calibration Autocompletes
TTS output triggers speech recognition

### Solution
Disable mic while TTS is speaking

### Implementation Steps

#### J.1: Fix Voice Calibration
**File**: `lib/screens/voice_calibration_screen.dart`

**Add TTS Completion Handler**:
```dart
Future<void> _speakInstruction(String text) async {
  setState(() => _isListening = false); // Disable listening

  await _ttsService.speak(text);

  // Wait extra 500ms after TTS completes
  await Future.delayed(Duration(milliseconds: 500));

  setState(() => _isListening = true); // Enable listening
}
```

#### J.2: UI Cleanup - Remove Extra Buttons
**File**: `lib/screens/welcome_screen.dart`

**Remove**:
- "Choose what to create" button
- "Quick start creature" button

**Keep**:
- Kid mode button (rename to "Start Creating" or "Let's Go!")

**Changes**:
```dart
// OLD:
Column(
  children: [
    MinecraftButton(text: 'Choose what to create', ...),
    MinecraftButton(text: 'Quick start creature', ...),
    MinecraftButton(text: 'Kid mode', ...),
  ],
)

// NEW:
Column(
  children: [
    // Single primary button
    MinecraftButton(
      text: l10n.startCreating, // "Start Creating" / "Börja Skapa"
      onPressed: () => Navigator.pushNamed(context, '/kid-friendly'),
      icon: Icons.auto_awesome,
    ),

    // Secondary button for settings (optional)
    TextButton(
      child: Text(l10n.settings),
      onPressed: () => Navigator.pushNamed(context, '/parent-settings'),
    ),
  ],
)
```

#### J.3: Add Translation
**File**: `lib/services/app_localizations.dart`

```dart
String get startCreating => _translate('Start Creating', 'Börja Skapa');
String get letsGo => _translate("Let's Go!", 'Vi Kör!');
```

### Files to Modify
- `lib/screens/voice_calibration_screen.dart` (+15 lines)
- `lib/screens/welcome_screen.dart` (-30 lines, +20 lines)
- `lib/services/app_localizations.dart` (+2 lines)

### Testing
- [ ] Voice calibration doesn't autocomplete
- [ ] Welcome screen has single primary button
- [ ] Button text is clear
- [ ] Translations work

---

## Implementation Order

### Session 1 (Most Critical)
1. **PHASE F** - First-run setup & API keys (2-3 hours)
2. **PHASE G** - Fix Minecraft export (2-3 hours)

**Result**: App can be configured properly and export works

### Session 2 (High Priority)
3. **PHASE H** - Fix creation history (1-2 hours)
4. **PHASE I** - Fix preview rendering (1-2 hours)

**Result**: Core creation flow works end-to-end

### Session 3 (Polish)
5. **PHASE J** - Voice calibration + UI cleanup (30 min)

**Result**: Polished, production-ready app

---

## Success Criteria

### After All Phases Complete:

✅ **First-Run Experience**
- [ ] Setup wizard appears on first launch
- [ ] Can configure API key easily
- [ ] Voice calibration works without autocomplete
- [ ] User knows app is ready to use

✅ **Creation Flow**
- [ ] Voice input works properly
- [ ] AI generates good quality creatures (using API)
- [ ] Preview shows accurate representation
- [ ] "Make changes" works and improves preview
- [ ] All creatures saved to history automatically

✅ **Export**
- [ ] Export succeeds every time
- [ ] File saved to accessible location
- [ ] User sees success message with file path
- [ ] Can share exported file
- [ ] Can open in Minecraft if installed

✅ **UI/UX**
- [ ] Clean, simple home screen
- [ ] Single "Start Creating" button
- [ ] Online/offline status visible
- [ ] Creation history up-to-date
- [ ] No confusing extra buttons

---

## Estimated Timeline

**Total**: 7-10 hours of development
- PHASE F: 2-3 hours
- PHASE G: 2-3 hours
- PHASE H: 1-2 hours
- PHASE I: 1-2 hours
- PHASE J: 30 minutes

**Recommended Schedule**:
- Day 1: PHASE F + PHASE G (4-6 hours)
- Day 2: PHASE H + PHASE I (2-4 hours)
- Day 3: PHASE J + testing (1 hour)

---

## Notes

- Phases can be parallelized if multiple developers
- Each phase is independently testable
- Phases F and G are blockers for full functionality
- Phases H, I, J are enhancements but important

---

**Ready to start implementation?**

Recommended: Begin with **PHASE F** (First-run setup & API keys)
