# Crafta Development Guide

## Getting Started

### Prerequisites Setup

1. **Install Flutter SDK**
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"

   # Verify installation
   flutter doctor
   ```

2. **Install Dependencies**
   ```bash
   # Android Studio (for Android development)
   # Download from https://developer.android.com/studio

   # Xcode (for iOS development, macOS only)
   # Download from Mac App Store
   ```

3. **Setup IDEs**
   - VS Code with Flutter extension
   - Android Studio with Flutter plugin
   - Configure emulators/simulators

### Project Setup

```bash
# Clone repository
git clone <repository-url>
cd crafta

# Install dependencies
flutter pub get

# Run on device
flutter devices          # List available devices
flutter run -d <device>  # Run on specific device
```

## Development Workflow

### 1. Feature Development

#### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/creature-animations

# Make changes
# ...

# Commit with descriptive message
git commit -m "feat: Add sparkle animation to creatures"

# Push to remote
git push origin feature/creature-animations
```

#### Commit Message Convention

```
feat: Add new feature
fix: Bug fix
docs: Documentation changes
style: Code style changes (formatting)
refactor: Code refactoring
test: Add or modify tests
chore: Maintenance tasks
```

### 2. Code Organization

#### File Structure Best Practices

```dart
// lib/screens/example_screen.dart

import 'package:flutter/material.dart';
import '../services/example_service.dart';
import '../widgets/example_widget.dart';

/// ExampleScreen shows [description]
///
/// Features:
/// - Feature 1
/// - Feature 2
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen>
    with TickerProviderStateMixin {

  // Services
  final _exampleService = ExampleService();

  // State variables
  String _data = '';
  bool _isLoading = false;

  // Controllers
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    // Initialization logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Build logic
    return Container();
  }
}
```

### 3. Testing

#### Unit Tests

Create test file: `test/services/example_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/services/example_service.dart';

void main() {
  group('ExampleService', () {
    late ExampleService service;

    setUp(() {
      service = ExampleService();
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
    });

    test('should process data correctly', () async {
      final result = await service.processData('test');
      expect(result, equals('expected_value'));
    });

    tearDown(() {
      service.dispose();
    });
  });
}
```

#### Widget Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/widgets/example_widget.dart';

void main() {
  testWidgets('ExampleWidget displays text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExampleWidget(text: 'Hello'),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });
}
```

#### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/example_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 4. Debugging

#### Debug Modes

```bash
# Debug mode (hot reload enabled)
flutter run

# Profile mode (performance profiling)
flutter run --profile

# Release mode (production build)
flutter run --release
```

#### Debug Tools

```dart
// Print debugging
print('Debug: $variable');

// Debug console
debugPrint('Important message');

// Assert statements
assert(value != null, 'Value must not be null');

// Debug breakpoints
debugger();  // Pauses execution in debug mode
```

#### Flutter DevTools

```bash
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

Features:
- Widget inspector
- Performance profiler
- Memory profiler
- Network monitor
- Logging

### 5. Adding New Features

#### Example: Adding a New Creature Type

1. **Update AI Service**

```dart
// lib/services/ai_service.dart

String _getSystemPrompt() {
  return '''
You can help create:
- Cows, Pigs, Chickens, and Sheep  // Added Sheep
// ... rest of prompt
''';
}

Map<String, dynamic> parseCreatureAttributes(String response) {
  // Add sheep detection logic
  if (response.toLowerCase().contains('sheep')) {
    attributes['type'] = 'sheep';
  }
  // ...
}
```

2. **Update 3D Renderer**

```dart
// lib/services/3d_renderer_service.dart

Creature3DModel generateCreatureMesh({
  required String creatureType,
  // ...
}) {
  switch (creatureType) {
    case 'cow':
      return _generateCowMesh();
    case 'pig':
      return _generatePigMesh();
    case 'chicken':
      return _generateChickenMesh();
    case 'sheep':  // Add new case
      return _generateSheepMesh();
    default:
      return _generateDefaultMesh();
  }
}

Creature3DModel _generateSheepMesh() {
  // Implement sheep 3D model
  return Creature3DModel(
    vertices: [...],
    indices: [...],
    // ...
  );
}
```

3. **Add Tests**

```dart
// test/services/ai_service_test.dart

test('should parse sheep creature', () {
  final attributes = aiService.parseCreatureAttributes(
    'I want a fluffy white sheep'
  );
  expect(attributes['type'], equals('sheep'));
  expect(attributes['color'], equals('white'));
});
```

4. **Update Documentation**

Update README.md, API_REFERENCE.md with new creature type.

## Code Quality Guidelines

### 1. Dart Style Guide

```dart
// Good: Use const constructors
const Text('Hello');

// Good: Use meaningful variable names
final userAge = 10;

// Bad: Single letter variables (except loops)
final a = 10;

// Good: Extract complex logic to methods
Widget _buildCreatureCard(Creature creature) {
  return Card(/* ... */);
}

// Good: Use trailing commas for formatting
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Line 1'),
      Text('Line 2'),
    ],  // Trailing comma
  );
}
```

### 2. Error Handling

```dart
// Good: Handle errors gracefully
Future<String> fetchData() async {
  try {
    final response = await http.get(url);
    return response.body;
  } on SocketException {
    return 'No internet connection';
  } catch (e) {
    print('Error: $e');
    return 'Something went wrong';
  }
}

// Good: User-friendly error messages for children
String _getChildFriendlyError(String error) {
  if (error.contains('network')) {
    return 'Oops! Let\'s check your internet connection!';
  }
  return 'Let\'s try that again!';
}
```

### 3. Child Safety Validation

```dart
// Always validate AI responses
Future<String> _getAIResponse(String input) async {
  final response = await aiService.getCraftaResponse(input);

  // Validate response is child-safe
  if (!securityService.validateAIResponse(response)) {
    return 'Let me think of something better!';
  }

  return response;
}
```

### 4. Performance Best Practices

```dart
// Good: Dispose controllers
@override
void dispose() {
  _animationController.dispose();
  _textController.dispose();
  super.dispose();
}

// Good: Use const widgets when possible
const SizedBox(height: 16)

// Good: Avoid rebuilding entire widget tree
// Use Builder widgets for localized rebuilds

// Good: Cache expensive computations
final _cachedData = <String, dynamic>{};

dynamic getData(String key) {
  return _cachedData.putIfAbsent(
    key,
    () => _expensiveComputation(key),
  );
}
```

## Platform-Specific Development

### Android Development

#### Update Permissions

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

#### Build Configuration

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS Development

#### Update Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<dict>
  <key>NSMicrophoneUsageDescription</key>
  <string>Crafta needs microphone access for voice interaction</string>
</dict>
```

#### Build Configuration

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## Common Development Tasks

### Adding a New Screen

1. Create screen file: `lib/screens/new_screen.dart`
2. Add route in `lib/main.dart`:
   ```dart
   routes: {
     '/new-screen': (context) => const NewScreen(),
   }
   ```
3. Navigate to screen:
   ```dart
   Navigator.pushNamed(context, '/new-screen');
   ```

### Adding a New Service

1. Create service file: `lib/services/new_service.dart`
2. Define service class:
   ```dart
   class NewService {
     Future<void> initialize() async { }
     Future<void> performAction() async { }
   }
   ```
3. Use in screens:
   ```dart
   final _newService = NewService();
   await _newService.initialize();
   ```

### Updating Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Update specific package
flutter pub upgrade package_name

# Update pubspec.yaml manually then:
flutter pub get
```

## Troubleshooting

### Common Issues

#### 1. Build Errors

```bash
# Clean build artifacts
flutter clean

# Rebuild
flutter pub get
flutter run
```

#### 2. Gradle Errors (Android)

```bash
cd android
./gradlew clean
cd ..
flutter run
```

#### 3. CocoaPods Errors (iOS)

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

#### 4. Speech Recognition Not Working

- Check device has microphone permission
- Verify platform support (Android/iOS only)
- Test on physical device (emulator may not support)

#### 5. AI Service Errors

- Verify API key is correct
- Check internet connection
- Monitor API rate limits

### Debug Logs

```bash
# View all logs
flutter logs

# Filter logs
flutter logs | grep 'ERROR'

# View device logs (Android)
adb logcat

# View device logs (iOS)
idevicesyslog
```

## Best Practices Checklist

- [ ] Follow Crafta Constitution (Safe, Kind, Imaginative)
- [ ] Write unit tests for new services
- [ ] Write widget tests for new UI components
- [ ] Add documentation comments to public APIs
- [ ] Handle errors gracefully with child-friendly messages
- [ ] Dispose controllers and clean up resources
- [ ] Use const constructors where possible
- [ ] Follow Flutter/Dart style guidelines
- [ ] Test on both Android and iOS
- [ ] Validate AI responses for child safety
- [ ] Log errors for debugging
- [ ] Optimize performance (animations, memory)

## Useful Commands Reference

```bash
# Development
flutter run                    # Run app
flutter run --hot               # Enable hot reload
flutter run -d <device>        # Run on specific device

# Testing
flutter test                   # Run all tests
flutter test --coverage        # Generate coverage

# Building
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app
flutter build web              # Build web app

# Code Quality
flutter analyze                # Analyze code
dart format lib/               # Format code
flutter pub outdated           # Check outdated packages

# Debugging
flutter logs                   # View logs
flutter doctor                 # Check environment
flutter devices                # List devices

# Cleanup
flutter clean                  # Clean build artifacts
flutter pub cache repair       # Repair pub cache
```

---

*Following Crafta Constitution: Safe, Kind, Imaginative*

For additional help, see:
- [Architecture Documentation](ARCHITECTURE.md)
- [API Reference](API_REFERENCE.md)
- [Production Deployment Guide](PRODUCTION_DEPLOYMENT.md)
