# Testing Phase - Broken Into Small Testable Parts

**Date**: October 20, 2025
**Approach**: Build & test each component individually before integration
**Status**: Planning phase

---

## Test Phase Structure

### Phase T1: Voice Services Testing (2-3 hours)
Break down voice system into testable units

#### T1.1: Speech-to-Text Service Test
**Objective**: Verify microphone input works
**What to Test**:
- [ ] SpeechService initialization
- [ ] Microphone permission check
- [ ] Speech recognition starts
- [ ] Text output captured
- [ ] Error handling works

**Test File**: `test/services/speech_service_test.dart`
**Steps**:
1. Create simple test script
2. Run on actual Android device
3. Verify captured text appears in logs
4. Check error cases

**Success**: Console shows "Speech recognized: [user's words]"

---

#### T1.2: Text-to-Speech Service Test
**Objective**: Verify voice output works
**What to Test**:
- [ ] TTSService initializes
- [ ] speak() method works
- [ ] Voice plays through speaker
- [ ] Volume control works
- [ ] Speech rate control works
- [ ] Personality voices differ

**Test File**: `test/services/tts_service_test.dart`
**Steps**:
1. Create test to speak simple phrases
2. Run on device
3. Listen for audio output
4. Test rate/pitch/volume changes
5. Test personality switching

**Success**: Hear voice say "Hello from Crafta!" with appropriate personality

---

#### T1.3: Enhanced Voice AI Service Test
**Objective**: Verify AI integration
**What to Test**:
- [ ] Service initializes
- [ ] generateResponse() works
- [ ] Context/system prompt works
- [ ] Conversation history tracked
- [ ] Personality applied to response

**Test File**: `test/services/enhanced_voice_ai_service_test.dart`
**Steps**:
1. Call generateResponse with test input
2. Verify response returned
3. Check response reflects personality
4. Test conversation flow

**Success**: Response generated with personality applied

---

#### T1.4: Complete Voice Loop Test
**Objective**: End-to-end voice conversation
**What to Test**:
- [ ] Listen for input
- [ ] Send to AI
- [ ] Get response
- [ ] Play response audio

**Test File**: Test widget (simple screen)
**Steps**:
1. Create test screen with single button "Test Voice"
2. Press button
3. Say "Hello Crafta"
4. Hear response
5. Check response is relevant

**Success**: Full voice conversation works end-to-end

---

### Phase T2: 3D Rendering Testing (2 hours)
Test 3D model display in isolation

#### T2.1: Model Data Generation Test
**Objective**: Verify creature data generates correctly
**What to Test**:
- [ ] CreatureAttributes create valid JSON
- [ ] Geometry JSON valid
- [ ] Babylon.js format correct

**Test File**: `test/services/minecraft/geometry_generator_test.dart`
**Steps**:
1. Generate model for test creature
2. Print JSON to console
3. Validate JSON structure
4. Check for required fields

**Success**: Valid JSON printed that can load in Babylon.js

---

#### T2.2: HTML Generation Test
**Objective**: Verify Babylon.js HTML generates
**What to Test**:
- [ ] HTML template valid
- [ ] Model JSON embedded
- [ ] Babylon.js libraries included

**Test File**: Manual test in widget
**Steps**:
1. Generate HTML
2. Save to file
3. Open in web browser
4. Check for 3D object

**Success**: Open HTML in browser, see 3D cube/model

---

#### T2.3: WebView Loading Test
**Objective**: Verify Flutter WebView loads HTML
**What to Test**:
- [ ] WebView initializes
- [ ] HTML loads in WebView
- [ ] Model renders in app
- [ ] User can interact (rotate/zoom)

**Test File**: Manual widget test
**Steps**:
1. Create simple widget with WebView
2. Load test HTML
3. Run on device
4. Check if 3D model shows

**Success**: 3D model visible in WebView on device

---

#### T2.4: Preview Screen Integration Test
**Objective**: Full preview with creature
**What to Test**:
- [ ] CreaturePreviewScreen loads
- [ ] Creates model from attributes
- [ ] Displays in WebView
- [ ] Fallback works if WebView fails

**Test File**: Manual screen test
**Steps**:
1. Navigate to preview screen with creature data
2. Wait for render
3. Check if model shows
4. Try interaction

**Success**: See creature 3D model in preview screen

---

### Phase T3: Minecraft Export Testing (2-3 hours)
Test export to .mcpack files

#### T3.1: JSON Generation Test
**Objective**: Verify all export files generate
**What to Test**:
- [ ] manifest.json valid
- [ ] entity_behavior.json valid
- [ ] entity_client.json valid
- [ ] geometry.json valid
- [ ] texture generates

**Test File**: `test/services/minecraft_export_service_test.dart` (fix existing)
**Steps**:
1. Create test creature
2. Generate all JSON files
3. Print each to console
4. Validate structure
5. Check for missing fields (like minecraft:movement.fly)

**Success**: All JSON files valid, no compilation errors

---

#### T3.2: File Creation Test
**Objective**: Verify .mcpack ZIP creation
**What to Test**:
- [ ] ZIP file created
- [ ] All files included
- [ ] Can unzip locally
- [ ] File size reasonable

**Test File**: Manual test in widget
**Steps**:
1. Generate export
2. Check file exists on device
3. Download and extract
4. Verify contents

**Success**: .mcpack file created with correct contents

---

#### T3.3: Minecraft Import Test
**Objective**: Verify Minecraft can read export
**What to Test**:
- [ ] Open .mcpack on device with Minecraft
- [ ] Minecraft accepts it
- [ ] Creature appears in game
- [ ] Works correctly in-game

**Test File**: Manual device test
**Steps**:
1. Export creature
2. Transfer .mcpack to device
3. Open in Minecraft Bedrock
4. Try to use creature

**Success**: Creature imports and works in Minecraft

---

### Phase T4: Voice-First Creator Flow Test (3-4 hours)
Test complete user journey

#### T4.1: Welcome & Personalization
**Objective**: Voice greets user, sets up personality
**What to Test**:
- [ ] App starts silently (no text)
- [ ] Crafta greets with voice
- [ ] Asks for personality choice via voice
- [ ] User selects by voice
- [ ] Personality confirmed

**Test File**: Manual widget test
**Steps**:
1. Run app
2. Hear greeting
3. Say personality name
4. Verify it's selected

**Success**: Child hears greeting, sets personality by voice

---

#### T4.2: Item Creation Loop
**Objective**: Voice guides through creation
**What to Test**:
- [ ] "What do you want to make?" prompt
- [ ] User speaks item type
- [ ] AI confirms understanding
- [ ] Asks for attributes (color, size, etc.)
- [ ] Each input works via voice

**Test File**: Manual screen test
**Steps**:
1. Start creation flow
2. Speak "red cow"
3. Follow voice prompts
4. Speak each attribute
5. Reach preview screen

**Success**: Complete item created through voice alone

---

#### T4.3: Preview Screen
**Objective**: Show 3D model, get voice approval
**What to Test**:
- [ ] Model renders
- [ ] Voice says "Do you like it?"
- [ ] User says "yes" or "no"
- [ ] Handles response appropriately

**Test File**: Manual screen test
**Steps**:
1. Get to preview with creature
2. Model displays
3. Hear voice prompt
4. Say "yes"
5. Continue to export

**Success**: Hear voice, respond, proceed correctly

---

#### T4.4: Export & Complete
**Objective**: Save to Minecraft and celebrate
**What to Test**:
- [ ] Export triggered
- [ ] Success confirmed via voice
- [ ] Files saved
- [ ] Can repeat or exit

**Test File**: Manual screen test
**Steps**:
1. Export creature
2. Hear success message
3. Verify files created
4. Test repeat creation

**Success**: Creature exported, user celebrated, can create again

---

## Testing Execution Order

```
Start Here (must be first):
  ↓
T1.1: Speech-to-Text ← Required for everything else
  ↓
T1.2: Text-to-Speech ← Feedback for user
  ↓
T1.3: Enhanced Voice AI ← Response generation
  ↓
T1.4: Complete Voice Loop ← First end-to-end
  ↓
Parallel paths (can do simultaneously):
  ├─→ T2.1: Model Data
  │    ├─→ T2.2: HTML Gen
  │    ├─→ T2.3: WebView
  │    └─→ T2.4: Preview Screen
  │
  ├─→ T3.1: JSON Gen
  │    ├─→ T3.2: File Creation
  │    └─→ T3.3: Minecraft Import
  │
  └─→ (Wait for T1.4 to complete)
         ↓
T4.1: Welcome Flow
  ↓
T4.2: Creation Loop
  ↓
T4.3: Preview & Approval
  ↓
T4.4: Export & Complete
```

---

## Testing Tools & Scripts

### Test 1: Voice Input/Output Validator
```dart
// File: lib/test_utils/voice_tester.dart
class VoiceTester {
  static Future<void> testSpeechInput() async {
    // Test microphone input
  }

  static Future<void> testTextOutput() async {
    // Test voice output
  }

  static Future<void> testFullLoop() async {
    // Test complete conversation
  }
}
```

### Test 2: 3D Model Validator
```dart
// File: lib/test_utils/model_tester.dart
class ModelTester {
  static String generateTestHTML() {
    // Generate valid Babylon.js HTML
  }

  static bool validateJSON(String json) {
    // Validate export JSON
  }
}
```

### Test 3: Export Validator
```dart
// File: lib/test_utils/export_tester.dart
class ExportTester {
  static Future<bool> testExport() async {
    // Test full export pipeline
  }

  static bool validateMCPack(File file) {
    // Validate .mcpack structure
  }
}
```

---

## Success Metrics

| Test | Status | Notes |
|------|--------|-------|
| T1.1 Speech-to-Text | ⏳ Pending | Can hear "Speech recognized: X" in logs |
| T1.2 Text-to-Speech | ⏳ Pending | Can hear voice output with personality |
| T1.3 Voice AI | ⏳ Pending | Response generated with context |
| T1.4 Voice Loop | ⏳ Pending | Full conversation works |
| T2.1 Model Data | ⏳ Pending | Valid JSON output |
| T2.2 HTML Gen | ⏳ Pending | Opens in browser |
| T2.3 WebView | ⏳ Pending | Model displays in app |
| T2.4 Preview | ⏳ Pending | Full screen works |
| T3.1 JSON Gen | ⏳ Pending | All files valid |
| T3.2 File Creation | ⏳ Pending | .mcpack created |
| T3.3 Import | ⏳ Pending | Works in Minecraft |
| T4.1 Welcome | ⏳ Pending | Voice greeting works |
| T4.2 Creation | ⏳ Pending | Voice guides creation |
| T4.3 Preview | ⏳ Pending | Model + voice approval |
| T4.4 Export | ⏳ Pending | Full flow works |

---

## Notes

- **DO NOT** move to next test until current passes
- **Document each failure** - helps with debugging
- **Run on real device** - emulator doesn't support audio well
- **Add logging** - console output helps verify what's happening
- **Video record successful tests** - proof of working features
- **Keep todo list updated** - mark tests as they complete

---

**Testing Plan Created**: October 20, 2025
**Target Completion**: 12-18 hours of work
**Next Step**: Start with T1.1 (Speech-to-Text)
