# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🚨 CURRENT WORK (October 22, 2025)

**Status**: Firebase Image Service infrastructure complete - Ready to integrate into preview screen

**Latest APK**: `~/Downloads/Crafta_FIREBASE_READY_20251022.apk` (65MB)

### Recent Fixes (Oct 21-22, 2025):
1. ✅ **Type validation** - OpenAI returning wrong types (sword→dragon) is caught by validation
2. ✅ **Color validation** - OpenAI returning wrong colors (black→red) is caught by validation
3. ✅ **Fallback system** - If AI fails validation, local parser extracts type/color from user input
4. ✅ **Name generation** - Fallback creates names like "Black Sword", "Golden Helmet"
5. ✅ **JSON mode** - Forced OpenAI to return JSON only (no conversational text)
6. ✅ **Temperature lowered** - 0.7 → 0.1 for more literal responses

### Known Issues:
- ⚠️ **No image previews** - Currently shows 2D emoji placeholders only
- ⚠️ **Suggestions irrelevant** - "Export" button suggests unrelated items

### Next Steps:
1. **Add Firebase Imagen** for real 3D-style Minecraft images (IN PROGRESS)
2. Fix suggestion algorithm to match created item
3. Test on real device

**Testing Results** (User feedback Oct 22):
- ✅ "golden helmet" → type: helmet, color: gold (AFTER fix)
- ✅ "glowing red sword" → type: sword, color: red
- ✅ "black dragon red eyes" → type: dragon, color: black
- ✅ Names display correctly

**See `FIREBASE_IMAGEN_INTEGRATION.md` for implementation details.**

---

## Project Vision: Crafta - AI-Powered Minecraft Mod Creator for Kids

**Core Mission**: Empower children ages 3-10 (especially non-readers) to become game creators using voice interaction. Kids describe what they want to create → AI generates it → AI suggests improvements → User agrees/disagrees via voice → 3D preview → Export to Minecraft.

**Crafta Constitution**: All features follow Safe • Kind • Imaginative principles.

---

## Quick Start Commands

```bash
# Development
flutter pub get                    # Install dependencies
flutter run -d android             # Run on Android device
flutter run -d ios                 # Run on iOS device
flutter run --hot                  # Enable hot reload

# Testing
flutter test                        # Run all tests (57+)
flutter test test/services/        # Test specific service
flutter analyze                     # Code quality check

# Building
flutter build apk --release         # Android APK (release)
flutter build appbundle --release   # Android App Bundle
flutter build ios --release         # iOS release build

# Cleanup
flutter clean                       # Clean build artifacts
flutter doctor                      # Diagnose setup issues
```

---

## Architecture Overview

### High-Level Flow

```
User speaks request → AI parses → Creates item → AI suggests improvements →
User voice response (yes/no) → 3D preview → Export to Minecraft Bedrock
```

### Project Structure

```
lib/
├── main.dart                           # App entry, routing (7 routes)
├── screens/                            # UI Screens
│   ├── welcome_screen.dart             # Minecraft-themed welcome
│   ├── creator_screen_simple.dart      # Main interaction hub (voice + text)
│   ├── complete_screen.dart            # Success screen (achievement style)
│   ├── advanced_customization_screen.dart # 5-tab customization interface
│   ├── creature_preview_screen.dart    # 3D viewer (WebView)
│   ├── parent_settings_screen.dart     # Parental controls
│   └── [5+ additional screens]         # Export, history, settings
├── services/                           # Business Logic (20+ services)
│   ├── ai_service.dart                 # OpenAI/Groq/HF/Ollama integration
│   ├── enhanced_ai_service.dart        # AI parsing for creature attributes
│   ├── speech_service.dart             # Speech-to-text (kid-friendly)
│   ├── tts_service.dart                # Text-to-speech with personality
│   ├── app_localizations.dart          # Swedish/English translations
│   ├── language_service.dart           # Language switching
│   ├── local_storage_service.dart      # Creature persistence
│   ├── connectivity_service.dart       # Online/offline detection
│   ├── minecraft/                      # Minecraft export services
│   │   ├── minecraft_export_service.dart    # .mcpack generation
│   │   ├── entity_behavior_generator.dart  # Behavior pack JSON
│   │   ├── entity_client_generator.dart    # Client-side rendering
│   │   ├── texture_generator.dart          # Texture generation
│   │   ├── geometry_generator.dart         # 3D geometry definitions
│   │   └── manifest_generator.dart         # UUID/manifest handling
│   └── [utils/                          # Caching, optimization
│       ├── memory_optimizer.dart        # LRU cache
│       └── rendering_optimizer.dart     # LOD, particle pooling
├── models/                             # Data Models
│   ├── enhanced_creature_attributes.dart   # Creature properties (enums: Size, Ability, etc.)
│   ├── conversation.dart               # Chat history
│   └── minecraft/                      # Minecraft addon models
│       ├── addon_package.dart
│       ├── addon_metadata.dart
│       ├── behavior_pack.dart
│       └── resource_pack.dart
├── widgets/                            # Reusable UI Components
│   ├── minecraft_3d_preview.dart       # WebView 3D viewer
│   ├── procedural_creature_renderer.dart # CustomPaint rendering
│   ├── language_selector.dart          # Language toggle
│   ├── kid_friendly_components.dart    # Accessible UI elements
│   └── [misc widgets]                  # Dialogs, indicators
├── theme/
│   └── minecraft_theme.dart            # Minecraft colors, styles
└── core/
    └── result.dart                     # Result pattern for errors

test/
├── services/                           # 35+ service tests
├── screens/                            # 10+ widget tests
└── helpers/                            # Mock data, test utilities
```

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_tts` | Voice output (warm, personality-driven) |
| `speech_to_text` | Voice input (kid-friendly) |
| `http` | API calls to OpenAI/Groq/HF |
| `flutter_dotenv` | API key management (security) |
| `archive` | .mcpack ZIP file generation |
| `webview_flutter` | 3D preview (Babylon.js) |
| `shared_preferences` | Settings persistence |
| `provider` | State management (not currently used heavily) |

---

## Core Systems

### 1. AI Integration Pipeline

**Services Involved**: `EnhancedAIService`, `AIService`, `SwedishAIService`

**Flow**:
1. User speaks/types creature description
2. `EnhancedAIService.parseEnhancedCreatureRequest()` calls AI API
3. AI returns JSON with creature attributes (color, size, abilities, etc.)
4. Parses into `EnhancedCreatureAttributes` object
5. **Important**: Currently stored in MEMORY ONLY (not persisted to disk yet)

**Key Models**:
- `EnhancedCreatureAttributes` - Contains all creature data
  - Enums: `CreatureSize`, `SpecialAbility`, `GlowEffect`, `PersonalityType`
  - Lists: abilities, accessories, patterns
  - Colors: primaryColor, secondaryColor, accentColor (Flutter Color objects)

**AI Providers** (with fallback chain):
- OpenAI GPT-4o-mini (priority 1)
- Groq (priority 2)
- Hugging Face (priority 3)
- Ollama local (priority 4)
- Offline cache (priority 5 - 60+ preset creatures)

### 2. Voice System (Speech-to-Text + Text-to-Speech)

**Services Involved**: `SpeechService`, `TTSService`

**Speech Recognition**:
- `SpeechService` uses `speech_to_text` plugin
- Recognizes user speech in real-time
- Triggers on mic button press (hold-to-speak pattern)
- Works in Swedish & English

**Text-to-Speech**:
- `TTSService` uses `flutter_tts` plugin
- Crafta personality: warm, encouraging, funny
- Age-appropriate vocabulary (4-10 year olds)
- Different response types: suggestions, encouragement, questions
- Also works in Swedish & English

### 3. Localization (Swedish + English)

**Services Involved**: `AppLocalizations`, `LanguageService`

**Key File**: `lib/services/app_localizations.dart`

**Translation Pattern**:
```dart
String get welcomeTitle => _translate('Welcome to Crafta!', 'Välkommen till Crafta!');

String _translate(String en, String sv) {
  return locale.languageCode == 'sv' ? sv : en;
}
```

**Current Status**:
- ✅ Welcome screen - TRANSLATED
- ✅ Creator screen - TRANSLATED
- ✅ Complete screen - TRANSLATED
- ✅ Advanced customization - TRANSLATED
- ⚠️ Parent settings - PARTIALLY (needs more strings)
- ⚠️ Export screens - PARTIALLY

**Adding New Translations**:
1. Add property to `AppLocalizations`: `String get myString => _translate('EN', 'SV');`
2. Use in screen: `final l10n = AppLocalizations.of(context); Text(l10n.myString)`

### 4. Minecraft Export System

**Services Involved**: `MinecraftExportService`, `ManifestGenerator`, `EntityBehaviorGenerator`

**Export Process**:
1. User clicks "Export to Minecraft"
2. `MinecraftExportService.exportCreature()` creates addon package
3. Generates behavior pack (entity definitions, spawn eggs, commands)
4. Generates resource pack (textures, models, client-side data)
5. Creates manifest.json with UUIDs
6. Packages as ZIP (.mcpack file)
7. Saves to Downloads folder
8. User taps to import to Minecraft

**Generated Files**:
- `manifest.json` - Pack metadata and UUIDs
- `entity_behavior.json` - Creature behavior definition
- `entity_client.json` - Client-side rendering
- `geometry.json` - 3D model definition
- `default.png` - Creature texture
- `loot_table.json` - Drop items
- `spawn_rules.json` - Spawning conditions

### 5. Local Storage (Persistence)

**Service**: `LocalStorageService`

**Current Status**: ✅ Service exists, but NOT YET integrated into creator flow

**What it can do**:
- `saveCreature()` - Persist creature to app storage
- `loadCreatures()` - Get all saved creatures
- `getCreature(id)` - Retrieve specific creature
- `deleteCreature(id)` - Remove from storage

**TODO**: Hook into creator flow after AI parsing:
```dart
// After line 117 in creator_screen_simple.dart
final enhancedAttributes = await EnhancedAIService.parseEnhancedCreatureRequest(text);
// ADD THIS:
await LocalStorageService().saveCreature(enhancedAttributes.toMap());
```

### 6. 3D Preview (WebView)

**Widget**: `Minecraft3DPreview`

**Technology**: Babylon.js (WebGL) in WebView

**How it works**:
1. Generates HTML with Babylon.js scene
2. Renders 3D model based on creature attributes
3. User can rotate/zoom

**Current Limitation**: Placeholder implementation - needs proper Babylon.js integration

---

## Current Status (As of Oct 18, 2025)

### ✅ Completed
- Minecraft-themed UI (all screens restyled)
- Swedish translations (main screens)
- AI creature generation & parsing
- Voice input/output with kid-friendly personality
- Advanced customization interface (5 tabs)
- Minecraft export (.mcpack generation)
- APK builds successfully (28.9MB)
- Offline mode (60+ cached creatures)
- Local storage service (not integrated)

### ⚠️ In Progress
- Swedish translations (completeness)
- Local storage integration
- 3D preview refinement
- Advanced customization suggestions feature

### ❌ Not Yet Implemented
- Creature gallery/history UI
- Re-export previous creatures
- Minecraft world integration (direct launch from app)
- Multiplayer sharing
- Tutorial/onboarding

---

## Development Workflow

### Adding a Feature

1. **Start with the flow**: Where in the app should it appear?
2. **Create the screen**: Add to `lib/screens/`, update routes in `main.dart`
3. **Add service logic**: Create service in `lib/services/` if needed
4. **Add translations**: Add strings to `AppLocalizations`
5. **Test**: Write unit tests in `test/services/`, widget tests in `test/screens/`
6. **Polish UI**: Use Minecraft theme colors from `minecraft_theme.dart`

### Debugging

```bash
# View live logs
flutter logs

# Hot reload (after changes)
press 'r' in terminal during flutter run

# Check specific service behavior
flutter test test/services/ai_service_test.dart -v

# Profile memory usage
flutter run --profile
```

### Testing

**Test Coverage**: 57+ tests across services and widgets

```bash
# Run all
flutter test

# Run specific
flutter test test/services/local_storage_service_test.dart

# With coverage
flutter test --coverage
lcov --list coverage/lcov.info  # View coverage report
```

---

## Important Implementation Details

### Creature Attributes Model

```dart
class EnhancedCreatureAttributes {
  final String baseType;              // 'cow', 'sword', 'chair', etc.
  final Color primaryColor;           // Flutter Color object
  final Color secondaryColor;
  final Color accentColor;
  final CreatureSize size;            // enum: tiny, small, medium, large, giant
  final List<SpecialAbility> abilities; // enum list: flying, swimming, etc.
  final List<Accessory> accessories;
  final PersonalityType personality;  // enum: friendly, playful, shy, brave, curious
  final List<Pattern> patterns;       // enum list: stripes, spots, sparkles
  final TextureType texture;          // enum: smooth, rough, scaly, furry
  final GlowEffect glowEffect;        // enum: none, soft, bright, pulsing, rainbow
  final CreatureAnimationStyle animationStyle;
  final String customName;
  final String description;
}
```

### AI Suggestions Flow (TODO)

After creature created, AI should suggest improvements:

```dart
// Pseudo-code for what should happen:
1. Generate creature
2. Ask AI: "What's a fun improvement for this ${creature.name}?"
3. Present 2-3 suggestions to user
4. User selects suggestion via voice ("yes", "first one", "keep it")
5. If yes, regenerate with new attributes
6. Go to 3D preview
```

### Voice-First Design Principles

- **Always provide voice feedback** after any action
- **Use warm, encouraging tone** - never critical
- **Keep sentences short** - 5-10 words max
- **Use sound effects sparingly** - might startle young children
- **Provide haptic feedback** for button presses
- **Read everything aloud** - don't expect kids to read

---

## Minecraft Theme System

**File**: `lib/theme/minecraft_theme.dart`

**Color Palette**:
- `grassGreen` - #7CB342
- `dirtBrown` - #8B6F47
- `stoneGray` - #7F7F7F
- `goldOre` - #FCBE11 (titles, accents)
- `emerald` - #50C878
- `diamond` - #5DADE2
- `redstone` - #FF0000
- `coalBlack` - #1D1D21
- `lavaOrange` - #FF8C00
- `deepStone` - #3A3A3A

**Widgets**:
- `MinecraftButton` - Blocky button with hard shadow
- `MinecraftPanel` - Oak wood textured background
- `MinecraftText` - Gold text with glow effect
- `minecraftSlot()` - Inventory slot decoration
- `minecraftButton()` - Chest-style button

---

## Common Tasks

### Add a new screen

1. Create file: `lib/screens/my_screen.dart`
2. Extend `StatefulWidget` or `StatelessWidget`
3. Add route in `main.dart`:
   ```dart
   '/my-screen': (context) => const MyScreen(),
   ```
4. Navigate to it:
   ```dart
   Navigator.pushNamed(context, '/my-screen');
   ```

### Add AI provider

1. Create service: `lib/services/my_ai_service.dart`
2. Implement same interface as `AIService`
3. Add to provider list in `AIService.initialize()`
4. Set priority number

### Fix Swedish translation

1. Find hardcoded English string in screen
2. Add to `AppLocalizations`: `String get myString => _translate('EN', 'SV');`
3. Replace hardcoded string: `Text(l10n.myString)`
4. Rebuild APK

### Export APK for testing

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or copy to accessible location:
cp build/app/outputs/flutter-apk/app-release.apk ~/Crafta_Latest.apk
```

---

## Troubleshooting

### Speech recognition not working
- Test on real device (emulators often don't support)
- Check microphone permissions: Settings → Apps → Crafta → Permissions
- Verify SpeechService is initialized in creator_screen

### APK build fails
```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

### Translations not appearing
- Check if screen has `final l10n = AppLocalizations.of(context)`
- Verify string exists in `AppLocalizations`
- Rebuild (clean + pub get + run)

### 3D preview blank
- Check WebView initialization in `Minecraft3DPreview`
- Verify Babylon.js HTML is generated correctly
- Check browser console logs: `flutter logs`

---

## Key Files to Know

| File | Purpose | Priority |
|------|---------|----------|
| `lib/main.dart` | Entry point, routing | High |
| `lib/screens/creator_screen_simple.dart` | Main interaction loop | High |
| `lib/services/enhanced_ai_service.dart` | Creature parsing | High |
| `lib/services/app_localizations.dart` | Translations | High |
| `lib/theme/minecraft_theme.dart` | UI theme system | Medium |
| `lib/services/minecraft_export_service.dart` | Export to Minecraft | Medium |
| `lib/services/tts_service.dart` | Voice personality | Medium |
| `pubspec.yaml` | Dependencies | Low (rarely changes) |

---

## Next Priority Tasks

1. **Complete Swedish translations** - Parent settings screen still has English
2. **Integrate local storage** - Save creatures after creation
3. **Add creature gallery** - Browse previously created items
4. **Implement AI suggestions** - "What if we made it...?" feature
5. **Fix 3D preview** - Make Babylon.js integration work fully
6. **Add parental dashboard** - Monitor child's creations
7. **Minecraft world integration** - Direct launch from app

---

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Minecraft Bedrock Edition Format](https://docs.microsoft.com/minecraft/creator/)
- [OpenAI API Docs](https://platform.openai.com/docs)

---

**Last Updated**: October 18, 2025
**By**: Claude Code (Haiku 4.5)
**Status**: Production-Ready APK ✅
