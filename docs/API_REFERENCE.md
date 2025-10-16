# Crafta API Reference

## Overview

This document provides detailed API documentation for all services and key components in the Crafta application.

## Table of Contents

- [AIService](#aiservice)
- [SpeechService](#speechservice)
- [TTSService](#ttsservice)
- [3DRendererService](#3drendererservice)
- [AnimationService](#animationservice)
- [SecurityService](#securityservice)
- [MonitoringService](#monitoringservice)

---

## AIService

**File**: `lib/services/ai_service.dart`

AI integration service for GPT-4o-mini interactions.

### Configuration

```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY';
static const String _baseUrl = 'https://api.openai.com/v1';
```

### Methods

#### getCraftaResponse

Get AI response from Crafta personality.

```dart
Future<String> getCraftaResponse(String userMessage)
```

**Parameters**:
- `userMessage` (String): The user's voice input text

**Returns**:
- `Future<String>`: Crafta's response text

**Example**:
```dart
final aiService = AIService();
final response = await aiService.getCraftaResponse('I want a rainbow cow');
print(response); // "That sounds amazing! A rainbow cow would be so colorful..."
```

**Error Handling**:
- Network errors: Returns friendly fallback message
- API errors: Returns child-appropriate error message
- Never throws exceptions to user

#### parseCreatureAttributes

Extract creature attributes from AI response.

```dart
Map<String, dynamic> parseCreatureAttributes(String response)
```

**Parameters**:
- `response` (String): AI response text containing creature description

**Returns**:
- `Map<String, dynamic>`: Creature attributes
  - `type` (String): "cow", "pig", or "chicken"
  - `color` (String): Color name or "rainbow"
  - `effects` (List<String>): ["sparkles", "glows", "flies"]
  - `size` (String): "tiny", "normal", or "big"
  - `behavior` (String): "friendly" or "neutral"

**Example**:
```dart
final attributes = aiService.parseCreatureAttributes(
  'I created a rainbow cow with sparkles!'
);
// Returns: {
//   "type": "cow",
//   "color": "rainbow",
//   "effects": ["sparkles"],
//   "size": "normal",
//   "behavior": "friendly"
// }
```

### System Prompt

The AI uses a custom system prompt that enforces:
- Child-appropriate language (ages 4-10)
- Positive, encouraging tone
- Safety filters (no violence, fear, negativity)
- Crafta personality traits

---

## SpeechService

**File**: `lib/services/speech_service.dart`

Speech-to-Text functionality for voice input.

### Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ❌ Web (not supported)
- ❌ Desktop (not supported)

### Methods

#### initialize

Initialize speech recognition.

```dart
Future<bool> initialize()
```

**Returns**:
- `Future<bool>`: `true` if initialization successful

**Example**:
```dart
final speechService = SpeechService();
final initialized = await speechService.initialize();
if (initialized) {
  print('Speech recognition ready');
}
```

#### isAvailable

Check if speech recognition is available on current platform.

```dart
bool isAvailable()
```

**Returns**:
- `bool`: `true` if speech recognition available

#### startListening

Begin listening for voice input.

```dart
Future<void> startListening({
  required Function(String) onResult,
  Function(String)? onError,
})
```

**Parameters**:
- `onResult` (Function): Callback with recognized text
- `onError` (Function, optional): Error callback

**Example**:
```dart
await speechService.startListening(
  onResult: (text) {
    print('Recognized: $text');
  },
  onError: (error) {
    print('Error: $error');
  },
);
```

#### stopListening

Stop listening for voice input.

```dart
Future<void> stopListening()
```

**Example**:
```dart
await speechService.stopListening();
```

#### cancel

Cancel current speech recognition session.

```dart
Future<void> cancel()
```

---

## TTSService

**File**: `lib/services/tts_service.dart`

Text-to-Speech service for Crafta's voice output.

### Configuration

```dart
// Default settings
double pitch = 1.0;      // Voice pitch (0.5 - 2.0)
double rate = 0.5;       // Speech rate (0.0 - 1.0)
double volume = 1.0;     // Volume (0.0 - 1.0)
```

### Methods

#### initialize

Initialize TTS engine.

```dart
Future<void> initialize()
```

**Example**:
```dart
final ttsService = TTSService();
await ttsService.initialize();
```

#### speak

Speak text aloud.

```dart
Future<void> speak(String text)
```

**Parameters**:
- `text` (String): Text to speak

**Example**:
```dart
await ttsService.speak('Hello! I\'m Crafta!');
```

#### stop

Stop current speech.

```dart
Future<void> stop()
```

#### setVoice

Configure voice parameters.

```dart
Future<void> setVoice({
  double? pitch,
  double? rate,
  double? volume,
})
```

**Parameters**:
- `pitch` (double, optional): Voice pitch
- `rate` (double, optional): Speech rate
- `volume` (double, optional): Volume level

**Example**:
```dart
await ttsService.setVoice(
  pitch: 1.2,    // Slightly higher pitch for child-friendly voice
  rate: 0.5,     // Slower for clarity
  volume: 1.0,   // Full volume
);
```

#### getVoices

Get available voices on device.

```dart
Future<List<String>> getVoices()
```

**Returns**:
- `Future<List<String>>`: List of available voice names

---

## 3DRendererService

**File**: `lib/services/3d_renderer_service.dart`

Custom 3D rendering service for creature visualization.

### Data Structures

```dart
class Creature3DModel {
  List<Vector3> vertices;
  List<int> indices;
  List<Vector3> normals;
  Color baseColor;
  List<Effect> effects;
}

class Effect {
  String type;  // "sparkles", "glow", "particles"
  Map<String, dynamic> parameters;
}
```

### Methods

#### generateCreatureMesh

Generate 3D mesh for creature.

```dart
Creature3DModel generateCreatureMesh({
  required String creatureType,
  required String size,
  required Color color,
})
```

**Parameters**:
- `creatureType` (String): "cow", "pig", or "chicken"
- `size` (String): "tiny", "normal", or "big"
- `color` (Color): Base color

**Returns**:
- `Creature3DModel`: 3D model data

**Example**:
```dart
final renderer = 3DRendererService();
final model = renderer.generateCreatureMesh(
  creatureType: 'cow',
  size: 'normal',
  color: Colors.pink,
);
```

#### applyEffects

Apply visual effects to creature.

```dart
void applyEffects(Creature3DModel model, List<String> effects)
```

**Parameters**:
- `model` (Creature3DModel): 3D model
- `effects` (List<String>): Effect names

**Effects Available**:
- `"sparkles"`: Particle sparkles around creature
- `"glow"`: Glowing aura effect
- `"rainbow"`: Rainbow color cycling
- `"flies"`: Floating animation

#### render

Render creature to canvas.

```dart
void render(
  Canvas canvas,
  Size size,
  Creature3DModel model,
  Matrix4 transform,
)
```

**Parameters**:
- `canvas` (Canvas): Flutter canvas
- `size` (Size): Render size
- `model` (Creature3DModel): 3D model
- `transform` (Matrix4): Transformation matrix

---

## AnimationService

**File**: `lib/services/animation_service.dart`

Animation and visual effects service.

### Methods

#### createSparkleAnimation

Create sparkle particle animation.

```dart
AnimationController createSparkleAnimation(TickerProvider vsync)
```

**Parameters**:
- `vsync` (TickerProvider): Animation ticker

**Returns**:
- `AnimationController`: Animation controller

**Example**:
```dart
final animService = AnimationService();
final sparkleController = animService.createSparkleAnimation(this);
sparkleController.repeat();
```

#### createPulseAnimation

Create pulsing scale animation.

```dart
Animation<double> createPulseAnimation(
  AnimationController controller, {
  double from = 1.0,
  double to = 1.2,
})
```

**Parameters**:
- `controller` (AnimationController): Animation controller
- `from` (double): Start scale
- `to` (double): End scale

**Returns**:
- `Animation<double>`: Scale animation

#### playSuccessAnimation

Play success celebration animation.

```dart
Future<void> playSuccessAnimation(BuildContext context)
```

**Features**:
- Confetti effect
- Success sound (if available)
- Screen flash
- Haptic feedback

---

## SecurityService

**File**: `lib/services/security_service.dart`

Content filtering and child safety service.

### Methods

#### validateInput

Validate user input for safety.

```dart
bool validateInput(String input)
```

**Parameters**:
- `input` (String): User input text

**Returns**:
- `bool`: `true` if input is safe

**Checks**:
- No profanity
- No personal information (emails, phone numbers)
- No external URLs
- Age-appropriate content

#### validateAIResponse

Validate AI response before showing to child.

```dart
bool validateAIResponse(String response)
```

**Parameters**:
- `response` (String): AI response text

**Returns**:
- `bool`: `true` if response is safe

**Filters**:
- Violence or fear-inducing content
- Negative emotions (anger, sadness)
- Adult themes
- Inappropriate language

#### filterContent

Filter and sanitize content.

```dart
String filterContent(String content)
```

**Parameters**:
- `content` (String): Raw content

**Returns**:
- `String`: Filtered, child-safe content

---

## MonitoringService

**File**: `lib/services/monitoring_service.dart`

Analytics and monitoring service.

### Methods

#### logEvent

Log analytics event.

```dart
void logEvent(String eventName, {Map<String, dynamic>? parameters})
```

**Parameters**:
- `eventName` (String): Event name
- `parameters` (Map, optional): Event data

**Example**:
```dart
final monitoring = MonitoringService();
monitoring.logEvent('creature_created', parameters: {
  'type': 'cow',
  'color': 'rainbow',
  'hasEffects': true,
});
```

#### logError

Log error for debugging.

```dart
void logError(String error, {StackTrace? stackTrace})
```

#### trackPerformance

Track performance metric.

```dart
void trackPerformance(String metric, double value)
```

**Common Metrics**:
- `"ai_response_time"`: AI response time in ms
- `"3d_render_time"`: 3D rendering time in ms
- `"speech_recognition_time"`: STT processing time in ms
- `"app_launch_time"`: App startup time in ms

---

## Error Codes

### AI Service Errors

| Code | Message | Description |
|------|---------|-------------|
| `AI_001` | Network error | No internet connection |
| `AI_002` | API error | OpenAI API error |
| `AI_003` | Invalid response | Unexpected AI response format |
| `AI_004` | Rate limit | Too many requests |

### Speech Service Errors

| Code | Message | Description |
|------|---------|-------------|
| `SPEECH_001` | Not available | Speech recognition not available |
| `SPEECH_002` | Permission denied | Microphone permission not granted |
| `SPEECH_003` | No speech detected | No voice input detected |

### TTS Service Errors

| Code | Message | Description |
|------|---------|-------------|
| `TTS_001` | Not available | TTS not available on platform |
| `TTS_002` | Playback error | Error playing audio |

---

## Usage Examples

### Complete Voice Interaction Flow

```dart
class CreatorScreenExample extends StatefulWidget {
  @override
  _CreatorScreenExampleState createState() => _CreatorScreenExampleState();
}

class _CreatorScreenExampleState extends State<CreatorScreenExample> {
  final speechService = SpeechService();
  final aiService = AIService();
  final ttsService = TTSService();

  String recognizedText = '';
  String aiResponse = '';

  Future<void> handleVoiceInput() async {
    // 1. Initialize services
    await speechService.initialize();
    await ttsService.initialize();

    // 2. Start listening
    await speechService.startListening(
      onResult: (text) async {
        setState(() => recognizedText = text);

        // 3. Stop listening
        await speechService.stopListening();

        // 4. Get AI response
        final response = await aiService.getCraftaResponse(text);
        setState(() => aiResponse = response);

        // 5. Speak response
        await ttsService.speak(response);

        // 6. Parse creature attributes
        final attributes = aiService.parseCreatureAttributes(response);

        // 7. Navigate to preview
        if (attributes['type'] != null) {
          Navigator.pushNamed(context, '/creature-preview',
            arguments: attributes);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('You said: $recognizedText'),
          Text('Crafta says: $aiResponse'),
          ElevatedButton(
            onPressed: handleVoiceInput,
            child: Text('Talk to Crafta'),
          ),
        ],
      ),
    );
  }
}
```

---

*Following Crafta Constitution: Safe, Kind, Imaginative*
