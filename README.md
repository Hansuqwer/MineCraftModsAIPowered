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
- **AI-Powered Creativity**: Multiple AI providers (OpenAI, Groq, Hugging Face, Ollama) with intelligent fallbacks
- **3D Creature Preview**: See your creation come to life in real-time with Babylon.js WebView
- **Enhanced AI Suggestions**: Contextual and age-appropriate suggestions for continued creativity
- **Multi-Language Support**: English and Swedish with voice support
- **Child Safety**: Built-in content filtering and parental controls
- **Privacy-First**: COPPA/GDPR compliant, no personal data collection
- **Export to Minecraft**: Download ready-to-use Minecraft mod files (.mcpack format)
- **Offline Mode**: 60+ cached creature responses, works without internet
- **Creature Sharing**: Cloud sharing with 8-character share codes
- **Performance Optimized**: LRU caching, LOD rendering, particle pooling
- **Mobile-First**: Touch-friendly interface optimized for iOS/Android
- **Responsive Design**: Optimized for phones, tablets, and foldable devices

## Architecture

### Tech Stack

- **Framework**: Flutter 3.5.4
- **Language**: Dart 3.5.4
- **AI Backend**: OpenAI GPT-4o-mini, Groq, Hugging Face, Ollama (with fallbacks)
- **Voice**: speech_to_text, flutter_tts (multi-language support)
- **3D Rendering**: Babylon.js via WebView, vector_math
- **State Management**: Provider pattern
- **Localization**: flutter_localizations, intl
- **WebView**: webview_flutter for 3D previews

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
│   │   ├── export_management_screen.dart # Mod downloads
│   │   ├── export_minecraft_screen.dart # Minecraft export UI
│   │   └── minecraft_settings_screen.dart # Minecraft settings
│   ├── services/                    # Business logic (20+ services)
│   │   ├── ai_service.dart          # OpenAI integration
│   │   ├── enhanced_ai_service.dart # Enhanced AI suggestions
│   │   ├── groq_ai_service.dart     # Groq AI integration
│   │   ├── huggingface_ai_service.dart # Hugging Face integration
│   │   ├── ollama_ai_service.dart   # Ollama integration
│   │   ├── offline_ai_service.dart # Offline AI cache (60+ creatures)
│   │   ├── speech_service.dart      # Speech-to-Text
│   │   ├── tts_service.dart         # Text-to-Speech
│   │   ├── language_service.dart    # Multi-language support
│   │   ├── swedish_ai_service.dart  # Swedish AI responses
│   │   ├── responsive_service.dart  # Responsive design
│   │   ├── startup_service.dart     # App initialization
│   │   ├── updater_service.dart    # App updates
│   │   ├── debug_service.dart       # Remote debugging
│   │   ├── connectivity_service.dart # Network monitoring
│   │   ├── local_storage_service.dart # Data persistence
│   │   ├── performance_monitor.dart # Performance tracking
│   │   ├── minecraft/               # Minecraft export services
│   │   │   ├── minecraft_export_service.dart
│   │   │   ├── entity_behavior_generator.dart
│   │   │   ├── entity_client_generator.dart
│   │   │   ├── texture_generator.dart
│   │   │   ├── geometry_generator.dart
│   │   │   └── manifest_generator.dart
│   │   └── utils/                   # Utility services
│   │       ├── memory_optimizer.dart # LRU cache, memory management
│   │       └── rendering_optimizer.dart # LOD, particle pooling
│   ├── widgets/                     # Reusable UI components
│   │   ├── minecraft_3d_preview.dart # 3D WebView preview
│   │   ├── language_selector.dart   # Language switching
│   │   ├── update_dialog.dart       # App update dialog
│   │   ├── furniture_renderer.dart   # Furniture visualization
│   │   └── offline_indicator.dart   # Connectivity status
│   ├── models/                      # Data models
│   │   ├── conversation.dart        # Chat history model
│   │   └── minecraft/               # Minecraft data models
│   │       ├── addon_package.dart
│   │       ├── addon_metadata.dart
│   │       ├── behavior_pack.dart
│   │       ├── resource_pack.dart
│   │       └── addon_file.dart
│   └── core/                        # Core utilities
│       └── result.dart              # Result pattern for error handling
├── test/                            # Unit & widget tests (57+ tests)
│   ├── services/                    # Service tests
│   ├── screens/                     # Widget tests
│   └── helpers/                     # Test utilities
├── docs/                            # Documentation
│   ├── PRODUCTION_DEPLOYMENT.md     # Deployment guide
│   ├── SPEECH_TESTING_ALTERNATIVES.md # Testing strategies
│   ├── ARCHITECTURE.md              # System architecture
│   ├── API_REFERENCE.md             # API documentation
│   ├── DEVELOPMENT_GUIDE.md         # Development workflow
│   ├── SECURITY_AND_IMPROVEMENTS.md # Security & roadmap
│   └── INDEX.md                     # Documentation index
├── android/                         # Android-specific config
├── ios/                             # iOS-specific config
└── pubspec.yaml                     # Dependencies

~10,200 lines of Dart code
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

### ✅ Completed Features
- **Offline Mode**: 60+ cached creature responses, works without internet
- **Performance Optimization**: LRU caching, LOD rendering, particle pooling
- **Minecraft Export**: Complete .mcpack file generation
- **Creature Sharing**: Cloud sharing with share codes
- **Behavior Mapping**: Complete Minecraft components integration
- **Mobile Optimization**: Touch-friendly interface for iOS/Android
- **Comprehensive Testing**: 57+ test cases with 100% offline service coverage
- **Build System**: ✅ APK builds successfully - `build/app/outputs/flutter-apk/app-debug.apk`
- **Production Code**: ✅ 0 errors, all core functionality working
- **Creator Screen**: ✅ Working with simplified, clean implementation

### Future Enhancements
- [ ] Add more creature types (currently: 60+ offline creatures)
- [ ] Multiplayer creature sharing
- [ ] Tutorial/onboarding flow
- [ ] More customization options
- [ ] Achievement system
- [ ] Advanced 3D rendering features

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
