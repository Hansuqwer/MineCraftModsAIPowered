# Crafta - AI-Powered Minecraft Mod Creator

<div align="center">

**A magical voice-powered app for kids ages 4-10 to create custom Minecraft creatures**

*Following Crafta Constitution: Safe, Kind, Imaginative*

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

</div>

## Overview

**Crafta** is a mobile application that empowers children to become game creators through voice interaction with an AI companion. Kids can design custom Minecraft creatures by simply describing what they want to create - no typing, no complex interfaces, just pure imagination brought to life.

### Key Features

- **Voice-First Design**: Kids talk to Crafta, Crafta responds with voice
- **AI-Powered Creativity**: GPT-4o-mini creates personalized, child-safe responses
- **3D Creature Preview**: See your creation come to life in real-time
- **Child Safety**: Built-in content filtering and parental controls
- **Privacy-First**: COPPA/GDPR compliant, no personal data collection
- **Export to Minecraft**: Download ready-to-use Minecraft mod files

## Architecture

### Tech Stack

- **Framework**: Flutter 3.5.4
- **Language**: Dart 3.5.4
- **AI Backend**: OpenAI GPT-4o-mini
- **Voice**: speech_to_text, flutter_tts
- **3D Rendering**: vector_math, Custom renderer
- **State Management**: Provider pattern

### Project Structure

```
crafta/
├── lib/
│   ├── main.dart                    # App entry point & routing
│   ├── screens/                     # UI screens (7 screens)
│   │   ├── welcome_screen.dart      # Animated welcome
│   │   ├── creator_screen.dart      # Voice interaction hub
│   │   ├── complete_screen.dart     # Success celebration
│   │   ├── creature_preview_screen.dart # 3D visualization
│   │   ├── parent_settings_screen.dart  # Safety controls
│   │   ├── creation_history_screen.dart # History tracking
│   │   └── export_management_screen.dart # Mod downloads
│   ├── services/                    # Business logic (10 services)
│   │   ├── ai_service.dart          # OpenAI integration
│   │   ├── speech_service.dart      # Speech-to-Text
│   │   ├── tts_service.dart         # Text-to-Speech
│   │   ├── 3d_renderer_service.dart # 3D rendering
│   │   ├── animation_service.dart   # Visual effects
│   │   ├── production_service.dart  # Deployment utilities
│   │   ├── monitoring_service.dart  # Analytics & metrics
│   │   ├── performance_service.dart # Performance optimization
│   │   ├── security_service.dart    # Security & safety
│   │   └── support_service.dart     # User support
│   ├── widgets/                     # Reusable UI components
│   │   ├── creature_3d_preview.dart
│   │   ├── creature_preview.dart
│   │   └── enhanced_creature_preview.dart
│   └── models/                      # Data models
│       └── conversation.dart        # Chat history model
├── test/                            # Unit & widget tests
├── docs/                            # Documentation
│   ├── PRODUCTION_DEPLOYMENT.md     # Deployment guide
│   └── SPEECH_TESTING_ALTERNATIVES.md # Testing strategies
├── android/                         # Android-specific config
├── ios/                             # iOS-specific config
└── pubspec.yaml                     # Dependencies

~8,000 lines of Dart code
```

## Getting Started

### Prerequisites

- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- Android Studio / Xcode (for mobile development)
- OpenAI API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd crafta
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**

   Edit `lib/services/ai_service.dart` and add your OpenAI API key:
   ```dart
   static const String _apiKey = 'your-api-key-here';
   ```

   > ⚠️ **Security Note**: For production, use environment variables or secure storage

4. **Run the app**
   ```bash
   # On Android emulator/device
   flutter run -d android

   # On iOS simulator/device
   flutter run -d ios
   ```

### Platform-Specific Setup

#### Android
Add microphone permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS
Add microphone permissions to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Crafta needs microphone access for voice interaction</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Crafta uses speech recognition to understand your voice</string>
```

## Development

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/speech_service_test.dart

# Run with coverage
flutter test --coverage
```

### Building

```bash
# Debug build
flutter build apk --debug

# Release build for Android
flutter build appbundle --release

# Release build for iOS
flutter build ios --release
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Check for outdated dependencies
flutter pub outdated
```

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | sdk | Framework |
| http | ^1.5.0 | API requests |
| speech_to_text | ^6.6.0 | Voice input |
| flutter_tts | ^4.2.3 | Voice output |
| provider | ^6.1.5+1 | State management |
| vector_math | ^2.1.4 | 3D calculations |
| rive | ^0.12.4 | Animations |
| archive | ^4.0.7 | File compression |
| path_provider | ^2.1.5 | File storage |

## Crafta Constitution

All features and interactions follow these core principles:

### 1. Safe
- Child-safe AI responses with content filtering
- No violence, fear, negativity, or adult themes
- COPPA/GDPR compliant privacy protection
- Parental controls and monitoring

### 2. Kind
- Encouraging and positive interactions
- Every idea is celebrated, never criticized
- Supportive learning experience
- Gentle error handling ("Let's try again!" vs "Error")

### 3. Imaginative
- Creative creature generation
- Inspiring AI personality
- Colorful, engaging visual design
- Fun and playful interactions

## Crafta AI Personality

Crafta is designed with a specific personality:

- **Voice**: Warm, curious, kind, gentle humor
- **Vocabulary**: Simple, short sentences (age 4-10 appropriate)
- **Emotion Range**: Happy → Curious → Calm → Excited (never angry/sad)
- **Behavior**: Always asks questions, never issues commands
- **Fallback**: If unsure, asks kindly for clarification

## Features in Detail

### Voice Interaction
- Hands-free operation for young children
- Natural language understanding
- Real-time speech-to-text processing
- Child-friendly TTS responses

### AI Integration
- GPT-4o-mini for intelligent conversations
- Custom system prompt for child safety
- Context-aware responses
- Creative creature attribute parsing

### 3D Visualization
- Real-time creature preview
- Interactive rotation and zoom
- Visual effects (sparkles, glows)
- Smooth animations

### Parental Controls
- Safety settings dashboard
- Creation history monitoring
- Export management
- Age-appropriate content filters

## Roadmap

### Current Status: Production-Ready ✅

### Future Enhancements
- [ ] Add more creature types (currently: Cow, Pig, Chicken)
- [ ] Multiplayer creature sharing
- [ ] Tutorial/onboarding flow
- [ ] Offline mode support
- [ ] More customization options
- [ ] Achievement system
- [ ] Improved 3D rendering performance

## Documentation

- [Production Deployment Guide](docs/PRODUCTION_DEPLOYMENT.md)
- [Speech Testing Alternatives](docs/SPEECH_TESTING_ALTERNATIVES.md)

## Contributing

This is a private project. For contributions, please contact the maintainers.

## License

Private and proprietary. All rights reserved.

## Support

For issues or questions:
- Create an issue in the repository
- Contact: [Your contact information]

## Acknowledgments

- Built with Flutter & Dart
- Powered by OpenAI GPT-4o-mini
- Designed for children ages 4-10
- Inspired by the joy of creative play

---

<div align="center">

**Made with ❤️ for young creators**

*Safe • Kind • Imaginative*

</div>
