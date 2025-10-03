# Integration Tests

This directory contains integration tests for the PokiFairy app.

## Running Integration Tests

### Android

```bash
# Run on connected Android device or emulator
flutter test integration_test/app_test.dart

# Or use the drive command
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

### iOS

```bash
# Run on connected iOS device or simulator
flutter test integration_test/app_test.dart

# Or use the drive command
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Test Coverage

The integration tests cover:

1. **App Launch**: Verifies the app launches successfully
2. **Navigation**: Tests navigation between different screens
3. **AI Chat Workflow**: 
   - Sending messages
   - Receiving AI responses
   - Clearing chat history
4. **Model Selection Workflow**:
   - Viewing available models
   - Selecting a model
   - Refreshing model list
5. **End-to-End Workflows**:
   - Complete flow from model selection to chat
   - App lifecycle handling
   - Data persistence
6. **Error Handling**:
   - No model selected
   - Empty message submission
   - Permission denial

## Prerequisites

- Flutter SDK installed
- Android SDK or Xcode configured
- Connected device or emulator/simulator running
- Storage permissions granted (for model access)

## Notes

- Some tests may be skipped if certain conditions aren't met (e.g., no models available)
- Tests that require actual AI model files will only pass if models are properly installed
- Platform-specific tests may behave differently on Android vs iOS
- Integration tests take longer to run than unit tests due to UI interactions

## Troubleshooting

If tests fail:

1. Ensure the app builds successfully: `flutter build apk` or `flutter build ios`
2. Check that all dependencies are installed: `flutter pub get`
3. Verify device/emulator is properly connected: `flutter devices`
4. Check storage permissions are granted
5. Ensure AI model files are in the correct location (if testing AI features)

## Adding New Tests

When adding new integration tests:

1. Follow the existing test structure
2. Use descriptive test names
3. Add appropriate timeouts for async operations
4. Handle cases where UI elements might not be present
5. Clean up any test data after tests complete
