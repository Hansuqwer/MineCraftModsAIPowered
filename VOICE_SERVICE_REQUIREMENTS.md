# Voice Service Requirements Analysis

**Date**: October 19, 2025
**Phase**: Phase 4 - Voice Services Restoration
**Status**: Analysis Complete

---

## Overview

The Enhanced Voice AI Service was moved to `.bak` due to compilation errors. This document details:
1. Service architecture and dependencies
2. Missing methods and their implementations
3. Integration requirements
4. Implementation roadmap

---

## Service Structure

### EnhancedVoiceAIService.dart.bak
```dart
class EnhancedVoiceAIService {
  // Dependencies
  - TTSService (Text-To-Speech)
  - SpeechService (Speech Recognition)
  - AIService (AI Response Generation)
  - LocalStorageService (Persistence)

  // Public Methods (Existing)
  - initialize()
  - startConversation()
  - processVoiceInput()

  // Private Methods (Existing)
  - _analyzeUserInput()
  - _generateContextualResponse()
  - _buildSystemPrompt()
  - _buildConversationHistory()
  - _enhanceResponse()
  - _getPersonalityResponse()
}

enum VoicePersonality {
  friendlyTeacher,
  playfulFriend,
  wiseMentor,
  creativeArtist,
  encouragingCoach
}
```

---

## Missing Public Methods

### 1. getCurrentPersonality()
**Error Location**: `main.dart:58`, `enhanced_modern_screen.dart:91`

**Required Signature**:
```dart
static Future<VoicePersonality> getCurrentPersonality() async {
  // Load from storage and return current personality
  // Default: VoicePersonality.friendlyTeacher
}
```

**Purpose**: Get currently selected voice personality
**Implementation**: Read from LocalStorageService with key "voice_personality"

---

### 2. generateVoiceResponse()
**Error Location**: `enhanced_modern_screen.dart:124`

**Required Signature**:
```dart
static Future<String> generateVoiceResponse(String prompt) async {
  // Generate AI response with current personality
  // Return response as string
}
```

**Purpose**: Generate response for given prompt with personality
**Implementation**:
- Extract personality
- Call _generateContextualResponse()
- Return response

---

### 3. setPersonality()
**Error Location**: `enhanced_modern_screen.dart:697`, line 715, 733, 751

**Required Signature**:
```dart
static Future<void> setPersonality(String personalityName) async {
  // Set current personality by name
  // Persist to storage
}
```

**Purpose**: Change voice personality
**Implementation**:
- Parse personality name to enum
- Update _currentPersonality
- Save to LocalStorageService

---

### 4. getCurrentLanguage()
**Error Location**: `enhanced_modern_screen.dart:90`

**Required Signature**:
```dart
static Future<String> getCurrentLanguage() async {
  // Get current language setting
  // Default: 'en'
}
```

**Purpose**: Get currently selected language
**Implementation**: Read from LocalStorageService with key "voice_language"

---

## Missing Enum Properties

### VoicePersonality Extensions

**Missing Properties**:
```dart
extension VoicePersonalityExt on VoicePersonality {
  String get emoji {
    // Return emoji representing personality
  }

  String get description {
    // Return human-readable description
  }
}
```

**Implementation Details**:
```dart
String get emoji {
  switch (this) {
    case VoicePersonality.friendlyTeacher:
      return '👨‍🏫';
    case VoicePersonality.playfulFriend:
      return '😄';
    case VoicePersonality.wiseMentor:
      return '🧙';
    case VoicePersonality.creativeArtist:
      return '🎨';
    case VoicePersonality.encouragingCoach:
      return '💪';
  }
}

String get description {
  switch (this) {
    case VoicePersonality.friendlyTeacher:
      return 'Warm, educational, and patient';
    case VoicePersonality.playfulFriend:
      return 'Fun, energetic, and silly';
    case VoicePersonality.wiseMentor:
      return 'Thoughtful, guiding, and wise';
    case VoicePersonality.creativeArtist:
      return 'Imaginative, expressive, and artistic';
    case VoicePersonality.encouragingCoach:
      return 'Motivational, supportive, and positive';
  }
}
```

---

## Dependent Service Methods

### AIService Missing Methods

**Location**: `lib/services/ai_service.dart`

#### 1. generateResponse()
**Used By**: EnhancedVoiceAIService line 252

**Required Signature**:
```dart
Future<String> generateResponse(
  String userInput, {
  String? systemPrompt,
  List<String>? conversationHistory,
}) async {
  // Generate response using AI
  // Handle system prompt and conversation context
}
```

**Implementation**:
- Build API request with Claude
- Include system prompt if provided
- Include conversation history if provided
- Parse and return response

---

### TTSService Missing Methods

**Location**: `lib/services/tts_service.dart`

#### 1. setSpeechRate()
**Used By**: `voice_personality_service.dart:75`

**Required Signature**:
```dart
Future<void> setSpeechRate(double rate) async {
  // Set speech rate (0.5 to 2.0)
  // Persist setting
}
```

#### 2. setPitch()
**Used By**: `voice_personality_service.dart:76`

**Required Signature**:
```dart
Future<void> setPitch(double pitch) async {
  // Set pitch (0.5 to 2.0)
  // Persist setting
}
```

#### 3. setVolume()
**Used By**: `voice_personality_service.dart:77`

**Required Signature**:
```dart
Future<void> setVolume(double volume) async {
  // Set volume (0.0 to 1.0)
  // Persist setting
}
```

---

### LocalStorageService Missing Methods

**Location**: `lib/services/local_storage_service.dart`

#### 1. getData()
**Used By**: `enhanced_voice_ai_service.dart:392`

**Required Signature**:
```dart
Future<dynamic> getData(String key) async {
  // Retrieve stored data by key
  // Return null if not found
}
```

**Implementation**: Use SharedPreferences

#### 2. removeData()
**Used By**: `enhanced_voice_ai_service.dart:405`

**Required Signature**:
```dart
Future<void> removeData(String key) async {
  // Remove stored data by key
}
```

**Implementation**: Use SharedPreferences

---

## VoicePersonalityService Issues

**File**: `lib/services/voice_personality_service.dart`

**Issues**:
1. Lines 75-77: Calls non-existent TTSService methods
2. Needs `setSpeechRate()`, `setPitch()`, `setVolume()` implementations
3. Should be re-enabled after TTSService fixes

---

## Dependencies Overview

```
EnhancedVoiceAIService
├── TTSService (needs 3 methods)
├── SpeechService (OK)
├── AIService (needs 1 method)
└── LocalStorageService (needs 2 methods)

VoicePersonalityService
└── TTSService (needs 3 methods)
```

---

## Implementation Checklist

### Phase 1: AIService
- [ ] Add `generateResponse()` method
- [ ] Add parameter handling
- [ ] Add error handling

### Phase 2: TTSService
- [ ] Add `setSpeechRate()` method
- [ ] Add `setPitch()` method
- [ ] Add `setVolume()` method
- [ ] Add setting persistence

### Phase 3: LocalStorageService
- [ ] Add `getData()` method
- [ ] Add `removeData()` method
- [ ] Add error handling

### Phase 4: VoicePersonalityService
- [ ] Fix TTSService method calls
- [ ] Test personality switching
- [ ] Verify persistence

### Phase 5: EnhancedVoiceAIService
- [ ] Add static methods
- [ ] Add VoicePersonality extensions (emoji, description)
- [ ] Re-enable voice service

### Phase 6: Restore to Build
- [ ] Restore service files from `.bak`
- [ ] Update imports in main.dart
- [ ] Test compilation
- [ ] Build APK

---

## Key Integration Points

### Storage Keys Required
```
voice_personality    → VoicePersonality enum value
voice_language       → Language code string
speech_rate          → Double (0.5-2.0)
pitch                → Double (0.5-2.0)
volume               → Double (0.0-1.0)
conversation_history → JSON string array
```

### API Integration Points
- Claude API for AI responses
- Text-to-speech for audio output
- Speech-to-text for voice input

---

## Testing Strategy

### Unit Tests
```dart
test('getCurrentPersonality returns valid personality');
test('setPersonality persists to storage');
test('generateVoiceResponse returns string');
test('TTSService setSpeechRate updates setting');
test('LocalStorageService getData retrieves values');
```

### Integration Tests
```dart
test('Full voice input → AI response → TTS flow');
test('Personality switching persists across sessions');
test('Error handling in all services');
```

---

## Estimated Implementation Time

| Task | Hours | Priority |
|------|-------|----------|
| AIService fixes | 2 | HIGH |
| TTSService methods | 2 | HIGH |
| LocalStorageService methods | 1.5 | HIGH |
| VoicePersonalityService fixes | 1.5 | HIGH |
| EnhancedVoiceAIService static methods | 2 | MEDIUM |
| VoicePersonality extensions | 1 | MEDIUM |
| Testing | 3 | HIGH |
| **Total** | **13** | - |

---

## Files to Modify

1. `lib/services/ai_service.dart` - Add generateResponse()
2. `lib/services/tts_service.dart` - Add 3 methods
3. `lib/services/local_storage_service.dart` - Add 2 methods
4. `lib/services/enhanced_voice_ai_service.dart` (from .bak) - Add static methods + extensions
5. `lib/services/voice_personality_service.dart` - Fix method calls
6. `lib/main.dart` - Re-enable imports and initialization

---

## Success Criteria

- [ ] All compilation errors resolved
- [ ] All services build without errors
- [ ] All methods implemented and functional
- [ ] Voice service can be re-enabled
- [ ] APK builds successfully
- [ ] Voice features testable in app

---

**Analysis Completed**: October 19, 2025
**Next Step**: Implement AIService.generateResponse()
