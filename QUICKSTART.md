# Crafta Quick Start Guide

Get Crafta running in 5 minutes!

## Prerequisites

- Flutter SDK 3.5.4+
- An OpenAI API key ([Get one here](https://platform.openai.com/api-keys))
- Android device/emulator OR iOS device/simulator

## Installation Steps

### 1. Clone & Install

```bash
# Clone the repository
git clone <repository-url>
cd crafta

# Install dependencies
flutter pub get
```

### 2. Configure API Key

Create a `.env` file in the project root:

```bash
# Create .env file
cat > .env << EOF
OPENAI_API_KEY=sk-your-actual-key-here
EOF
```

**Important**: Add `.env` to `.gitignore` to keep your key secure!

```bash
echo ".env" >> .gitignore
```

### 3. Add Environment Package

```bash
# Add flutter_dotenv
flutter pub add flutter_dotenv
```

Update [pubspec.yaml](pubspec.yaml):

```yaml
flutter:
  assets:
    - .env
```

### 4. Update Main App

Edit [lib/main.dart](lib/main.dart):

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");  // Add this line
  runApp(const CraftaApp());
}
```

### 5. Update AI Service

Edit [lib/services/ai_service.dart](lib/services/ai_service.dart):

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // Replace hardcoded key with:
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Rest of the code...
}
```

### 6. Run the App

```bash
# List available devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on specific device
flutter run -d <device-id>
```

## Testing Voice Features

### On Real Device (Recommended)

1. Connect your Android/iOS device via USB
2. Enable USB debugging (Android) or trust computer (iOS)
3. Run: `flutter run`
4. Grant microphone permissions when prompted
5. Tap the microphone button and speak!

### On Emulator/Simulator

Speech recognition may not work on emulators. Use the mock test instead:

```bash
# Run the test app with mock voice input
flutter run test_speech.dart
```

Click the robot icon to simulate voice input.

## First Creature Creation

1. Launch the app
2. Tap "Start Creating" on welcome screen
3. Tap the microphone button
4. Say: **"I want to create a rainbow cow with sparkles"**
5. Watch Crafta respond!
6. Tap "See My Creature" to view in 3D

## Common Issues

### Issue: "API key not found"

**Solution**: Verify your `.env` file exists and contains your key:

```bash
cat .env
# Should show: OPENAI_API_KEY=sk-...
```

### Issue: "Speech recognition not available"

**Solution**:
- Test on a real device (emulators often don't support speech)
- Grant microphone permissions in device settings
- Use mock test mode for development

### Issue: "Build errors"

**Solution**:

```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "iOS CocoaPods errors"

**Solution**:

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## Next Steps

Once you have the app running:

1. **Read the docs**: Check out [README.md](README.md) for full overview
2. **Explore the code**: Start with [lib/main.dart](lib/main.dart) and [lib/screens/creator_screen.dart](lib/screens/creator_screen.dart)
3. **Make improvements**: See [docs/SECURITY_AND_IMPROVEMENTS.md](docs/SECURITY_AND_IMPROVEMENTS.md)
4. **Add features**: Follow [docs/DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md)

## Project Structure Quick Reference

```
crafta/
├── lib/
│   ├── main.dart              ← App entry point
│   ├── screens/               ← UI screens
│   │   └── creator_screen.dart ← Main interaction screen
│   ├── services/              ← Business logic
│   │   ├── ai_service.dart    ← OpenAI integration
│   │   ├── speech_service.dart ← Voice input
│   │   └── tts_service.dart   ← Voice output
│   └── widgets/               ← Reusable components
├── test/                      ← Tests
├── docs/                      ← Documentation
├── .env                       ← Your API key (create this!)
└── pubspec.yaml              ← Dependencies
```

## Useful Commands

```bash
# Development
flutter run --hot              # Hot reload enabled
flutter logs                   # View logs

# Testing
flutter test                   # Run tests
flutter analyze                # Check code

# Building
flutter build apk              # Android APK
flutter build ios              # iOS build

# Cleanup
flutter clean                  # Clean build
flutter doctor                 # Check setup
```

## Getting Help

- **Documentation**: See [docs/](docs/) folder
- **Issues**: Check existing issues or create new one
- **Architecture**: Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **API Reference**: See [docs/API_REFERENCE.md](docs/API_REFERENCE.md)

## Development Workflow

```bash
# 1. Make changes to code
# 2. Hot reload (press 'r' in terminal)
# 3. Test changes
# 4. Run tests: flutter test
# 5. Commit changes: git commit -m "feat: your change"
```

## Tips for Success

1. **Use a real device**: Speech features work best on actual hardware
2. **Check logs**: Use `flutter logs` to debug issues
3. **Start simple**: Modify existing screens before creating new ones
4. **Follow the Constitution**: Keep it Safe, Kind, and Imaginative
5. **Test on both platforms**: Android and iOS may behave differently

---

## That's It!

You're now ready to develop with Crafta. Have fun creating magical experiences for kids!

*Following Crafta Constitution: Safe • Kind • Imaginative*

For detailed documentation, see:
- [Complete README](README.md)
- [Architecture Guide](docs/ARCHITECTURE.md)
- [Development Guide](docs/DEVELOPMENT_GUIDE.md)
- [Security & Improvements](docs/SECURITY_AND_IMPROVEMENTS.md)
