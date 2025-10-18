#!/bin/bash

# 🔍 COMPREHENSIVE BUG DETECTION SCRIPT
# Automates bug detection and testing

echo "🔍 Starting Comprehensive Bug Detection..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Static Analysis
print_status "Running static analysis..."
flutter analyze --no-fatal-infos > analysis_results.txt 2>&1
if [ $? -eq 0 ]; then
    print_success "Static analysis passed"
else
    print_error "Static analysis found issues - check analysis_results.txt"
    cat analysis_results.txt
fi

# 2. Dependency Check
print_status "Checking dependencies..."
flutter pub deps > deps_results.txt 2>&1
if [ $? -eq 0 ]; then
    print_success "Dependencies resolved"
else
    print_error "Dependency issues found - check deps_results.txt"
fi

# 3. Build Test
print_status "Testing build process..."
flutter build apk --debug > build_results.txt 2>&1
if [ $? -eq 0 ]; then
    print_success "Build successful"
else
    print_error "Build failed - check build_results.txt"
    cat build_results.txt
fi

# 4. Test Suite
print_status "Running test suite..."
flutter test > test_results.txt 2>&1
if [ $? -eq 0 ]; then
    print_success "All tests passed"
else
    print_error "Tests failed - check test_results.txt"
    cat test_results.txt
fi

# 5. Code Quality Check
print_status "Checking code quality..."
dart analyze --fatal-infos > quality_results.txt 2>&1
if [ $? -eq 0 ]; then
    print_success "Code quality check passed"
else
    print_warning "Code quality issues found - check quality_results.txt"
    cat quality_results.txt
fi

# 6. Memory Leak Detection
print_status "Checking for potential memory leaks..."
grep -r "AnimationController" lib/ | grep -v "dispose" > memory_leaks.txt
if [ -s memory_leaks.txt ]; then
    print_warning "Potential memory leaks found:"
    cat memory_leaks.txt
else
    print_success "No obvious memory leaks detected"
fi

# 7. Null Safety Check
print_status "Checking null safety..."
grep -r "!" lib/ | grep -v "//" > null_safety.txt
if [ -s null_safety.txt ]; then
    print_warning "Potential null safety issues:"
    cat null_safety.txt
else
    print_success "No obvious null safety issues"
fi

# 8. Error Handling Check
print_status "Checking error handling..."
grep -r "catch" lib/ | wc -l > error_handling_count.txt
error_count=$(cat error_handling_count.txt)
print_status "Found $error_count catch blocks"

# 9. Performance Check
print_status "Checking for performance issues..."
grep -r "setState" lib/ | wc -l > setstate_count.txt
setstate_count=$(cat setstate_count.txt)
if [ $setstate_count -gt 50 ]; then
    print_warning "High number of setState calls: $setstate_count"
else
    print_success "Reasonable number of setState calls: $setstate_count"
fi

# 10. Security Check
print_status "Checking for security issues..."
grep -r "password\|secret\|key" lib/ | grep -v "//" > security_check.txt
if [ -s security_check.txt ]; then
    print_warning "Potential security issues found:"
    cat security_check.txt
else
    print_success "No obvious security issues"
fi

# 11. Generate Report
print_status "Generating bug detection report..."
cat > bug_detection_report.txt << EOF
🔍 COMPREHENSIVE BUG DETECTION REPORT
Generated: $(date)

📊 SUMMARY:
- Static Analysis: $(if [ -f analysis_results.txt ] && ! grep -q "error" analysis_results.txt; then echo "PASS"; else echo "FAIL"; fi)
- Dependencies: $(if [ -f deps_results.txt ] && ! grep -q "error" deps_results.txt; then echo "PASS"; else echo "FAIL"; fi)
- Build Test: $(if [ -f build_results.txt ] && ! grep -q "error" build_results.txt; then echo "PASS"; else echo "FAIL"; fi)
- Test Suite: $(if [ -f test_results.txt ] && ! grep -q "error" test_results.txt; then echo "PASS"; else echo "FAIL"; fi)
- Code Quality: $(if [ -f quality_results.txt ] && ! grep -q "error" quality_results.txt; then echo "PASS"; else echo "FAIL"; fi)

🐛 ISSUES FOUND:
$(if [ -s memory_leaks.txt ]; then echo "Memory Leaks:"; cat memory_leaks.txt; echo ""; fi)
$(if [ -s null_safety.txt ]; then echo "Null Safety Issues:"; cat null_safety.txt; echo ""; fi)
$(if [ -s security_check.txt ]; then echo "Security Issues:"; cat security_check.txt; echo ""; fi)

📈 METRICS:
- Error Handling Blocks: $error_count
- setState Calls: $setstate_count
- Potential Memory Leaks: $(wc -l < memory_leaks.txt)
- Null Safety Issues: $(wc -l < null_safety.txt)

🔧 RECOMMENDATIONS:
1. Review all ERROR results above
2. Fix memory leaks if any found
3. Address null safety issues
4. Improve error handling where needed
5. Optimize performance if setState count is high
6. Review security issues if any found

EOF

print_success "Bug detection complete! Check bug_detection_report.txt for details"

# Cleanup
rm -f analysis_results.txt deps_results.txt build_results.txt test_results.txt quality_results.txt memory_leaks.txt null_safety.txt error_handling_count.txt setstate_count.txt security_check.txt

echo "🎯 Bug detection script completed!"
