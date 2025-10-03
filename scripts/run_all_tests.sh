#!/bin/bash
# Comprehensive Test Runner for macOS/Linux
# Runs all types of tests: unit, widget, and integration

set -e

echo "========================================"
echo "PokiFairy Comprehensive Test Runner"
echo "========================================"
echo ""

# Run flutter analyze
echo "[1/4] Running flutter analyze..."
flutter analyze
echo "flutter analyze passed!"
echo ""

# Run all unit and widget tests
echo "[2/4] Running unit and widget tests..."
flutter test --no-pub --coverage
echo "All tests passed!"
echo ""

# Run integration tests (requires connected device)
echo "[3/4] Checking for connected devices..."
flutter devices
echo ""
read -p "Run integration tests? (requires connected device) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running integration tests..."
    flutter test integration_test/app_test.dart || echo "WARNING: Integration tests failed"
else
    echo "Integration tests skipped"
fi
echo ""

# Generate test coverage report
echo "[4/4] Test coverage report..."
if [ -f "coverage/lcov.info" ]; then
    echo "Coverage report generated at: coverage/lcov.info"
    echo "To view coverage report, use: genhtml coverage/lcov.info -o coverage/html"
else
    echo "No coverage data generated"
fi
echo ""

echo "========================================"
echo "Test Run Complete!"
echo "========================================"
echo ""
