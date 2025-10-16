# Crafta Automation Scripts

This directory contains automation scripts to streamline development, testing, and deployment.

## Available Scripts

### `automate_improvements.sh` (Phase 1)

**Purpose**: Automated testing, code quality checks, and build process (Phase 1: Security & Testing)

**What it does**:
1. ✅ Checks environment setup (.env file)
2. 📦 Installs Flutter dependencies
3. 🔍 Analyzes code for issues
4. ✨ Formats code according to Dart style guide
5. 🧪 Runs all unit tests with coverage
6. 📊 Generates coverage report
7. 🔒 Checks for security issues (hardcoded secrets)
8. 📈 Provides summary report
9. 🏗️ Optionally builds APK

**Usage**:
```bash
# Run from project root
./scripts/automate_improvements.sh
```

**Output Files**:
- `test_report.txt` - Test results
- `analysis_report.txt` - Code analysis results
- `coverage/html/index.html` - Coverage report (if lcov installed)

**Requirements**:
- Flutter SDK installed
- Bash shell
- Optional: `lcov` for HTML coverage reports

### `phase3_automation.sh` (Phase 3)

**Purpose**: Performance & Polish validation and testing (Phase 3)

**What it does**:
1. 📊 Runs all unit tests and counts results
2. 🌐 Tests offline mode functionality
3. 🔍 Analyzes code quality (errors, warnings, info)
4. 📦 Checks codebase statistics (files, lines, services)
5. 🦄 Counts offline creature responses
6. ✅ Validates new Phase 3 features (performance monitor, memory optimizer, rendering optimizer, offline indicator)
7. 📋 Generates PHASE3_RESULTS.txt summary report

**Usage**:
```bash
# Run from project root
./scripts/phase3_automation.sh
```

**Output Files**:
- `phase3_test_report.txt` - Test execution results
- `phase3_analysis.txt` - Code analysis output
- `PHASE3_RESULTS.txt` - Complete Phase 3 summary

**Requirements**:
- Flutter SDK installed
- Bash shell
- bc (calculator) for statistics

### Quick Commands

```bash
# Run Phase 1 automation script
./scripts/automate_improvements.sh

# Run Phase 3 automation script
./scripts/phase3_automation.sh

# Run only tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## CI/CD Integration

To integrate with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## Troubleshooting

### Script won't run
```bash
chmod +x scripts/automate_improvements.sh
```

### .env file missing
```bash
cp .env.example .env
# Then edit .env and add your API key
```

### Tests failing
```bash
# Check test output
cat test_report.txt

# Run specific test
flutter test test/services/ai_service_test.dart
```

### Coverage report not generating
```bash
# Install lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Install lcov (macOS)
brew install lcov
```

## Adding New Scripts

1. Create script in `scripts/` directory
2. Make it executable: `chmod +x scripts/your_script.sh`
3. Document it in this README
4. Test it thoroughly
5. Commit to repository

---

*Following Crafta Constitution: Safe • Kind • Imaginative*
