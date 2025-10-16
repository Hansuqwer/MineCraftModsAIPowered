#!/bin/bash
# Crafta Automated Improvement Script
# This script automates testing, building, and validation

set -e  # Exit on error

echo "🚀 Crafta Automated Improvement Script"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0.32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check environment
echo "📋 Step 1: Checking environment..."
if [ ! -f ".env" ]; then
    echo "${YELLOW}⚠️  .env file not found. Creating from .env.example...${NC}"
    cp .env.example .env
    echo "${GREEN}✅ Created .env file. Please add your API key before running the app.${NC}"
fi

# Step 2: Install dependencies
echo ""
echo "📦 Step 2: Installing dependencies..."
flutter pub get

# Step 3: Analyze code
echo ""
echo "🔍 Step 3: Analyzing code..."
flutter analyze | tee analysis_report.txt

# Step 4: Format code
echo ""
echo "✨ Step 4: Formatting code..."
dart format lib/ test/

# Step 5: Run tests
echo ""
echo "🧪 Step 5: Running tests..."
flutter test --coverage 2>&1 | tee test_report.txt

# Step 6: Generate coverage report
echo ""
echo "📊 Step 6: Generating coverage report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "${GREEN}✅ Coverage report generated in coverage/html/index.html${NC}"
else
    echo "${YELLOW}⚠️  genhtml not found. Install lcov to generate HTML coverage reports.${NC}"
fi

# Step 7: Check for security issues
echo ""
echo "🔒 Step 7: Checking for security issues..."
echo "   Checking for hardcoded secrets..."
if grep -r "sk-" lib/ --exclude-dir=.dart_tool 2>/dev/null | grep -v "test" | grep -v "example"; then
    echo "${RED}❌ Found potential hardcoded API keys!${NC}"
else
    echo "${GREEN}✅ No hardcoded API keys found${NC}"
fi

# Step 8: Build summary
echo ""
echo "📈 Step 8: Build Summary"
echo "========================"

# Count tests
total_tests=$(grep -o "All tests passed!" test_report.txt | wc -l || echo "0")
if [ "$total_tests" -gt 0 ]; then
    echo "${GREEN}✅ All tests passed!${NC}"
else
    failed_tests=$(grep -o "Some tests failed" test_report.txt | wc -l || echo "0")
    if [ "$failed_tests" -gt 0 ]; then
        echo "${RED}❌ Some tests failed. Check test_report.txt for details.${NC}"
    fi
fi

# Check analysis
errors=$(grep "error •" analysis_report.txt | wc -l || echo "0")
warnings=$(grep "warning •" analysis_report.txt | wc -l || echo "0")
echo ""
echo "Code Analysis:"
echo "  - Errors: $errors"
echo "  - Warnings: $warnings"

# Step 9: Build APK (optional)
echo ""
read -p "Would you like to build an APK? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏗️  Building APK..."
    flutter build apk --debug
    echo "${GREEN}✅ APK built successfully!${NC}"
    echo "   Location: build/app/outputs/flutter-apk/app-debug.apk"
fi

# Final summary
echo ""
echo "🎉 Automation Complete!"
echo "======================="
echo ""
echo "Next steps:"
echo "  1. Review test_report.txt for test results"
echo "  2. Review analysis_report.txt for code quality"
echo "  3. Check coverage/html/index.html for test coverage"
echo "  4. Add your OpenAI API key to .env file"
echo "  5. Run 'flutter run' to test the app"
echo ""
echo "${GREEN}✨ All done! Happy coding!${NC}"
