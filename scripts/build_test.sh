#!/bin/bash
# Build Test Script for macOS/Linux
# Tests Android and iOS builds

set -e

echo "========================================"
echo "PokiFairy Build Test Script"
echo "========================================"
echo ""

# Run flutter analyze
echo "[1/5] Running flutter analyze..."
flutter analyze
echo "flutter analyze passed!"
echo ""

# Run unit tests
echo "[2/5] Running unit tests..."
flutter test --no-pub
echo "Unit tests passed!"
echo ""

# Build Android Debug APK
echo "[3/5] Building Android Debug APK..."
flutter build apk --debug
echo "Android debug build successful!"
echo ""

# Build Android Release APK
echo "[4/5] Building Android Release APK..."
flutter build apk --release
echo "Android release build successful!"
echo ""

# Check if iOS build is available (macOS only)
echo "[5/5] Checking iOS build availability..."
if command -v xcodebuild &> /dev/null; then
    echo "Building iOS Debug..."
    flutter build ios --debug --no-codesign || echo "WARNING: iOS debug build failed"
    
    echo "Building iOS Release..."
    flutter build ios --release --no-codesign || echo "WARNING: iOS release build failed"
else
    echo "iOS build skipped (xcodebuild not available)"
fi
echo ""

echo "========================================"
echo "Build Test Complete!"
echo "========================================"
echo ""
echo "Build artifacts:"
echo "- Android Debug: build/app/outputs/flutter-apk/app-debug.apk"
echo "- Android Release: build/app/outputs/flutter-apk/app-release.apk"
if command -v xcodebuild &> /dev/null; then
    echo "- iOS builds: build/ios/iphoneos/"
fi
echo ""
