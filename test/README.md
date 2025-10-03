# PokiFairy Test Suite

This directory contains all tests for the PokiFairy application.

## Test Structure

```
test/
├── features/           # Feature-specific tests
│   ├── chat/          # Chat feature tests
│   │   ├── chat_page_test.dart
│   │   ├── chat_controller_test.dart
│   │   └── message_bubble_test.dart
│   └── ai_model/      # AI model feature tests
│       └── model_selection_page_test.dart
├── model/             # Data model tests
│   ├── ai_message_test.dart
│   ├── ai_model_info_test.dart
│   └── ai_exception_test.dart
├── providers/         # Provider tests
│   └── ai_providers_test.dart
├── services/          # Service layer tests
│   ├── ai_service_test.dart
│   └── model_manager_test.dart
└── l10n/             # Localization tests
    └── localization_test.dart
```

## Running Tests

### Run All Tests

```bash
# Windows
flutter test

# macOS/Linux
flutter test
```

### Run Specific Test File

```bash
flutter test test/features/chat/chat_page_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Run Tests in Watch Mode

```bash
flutter test --watch
```

## Test Types

### 1. Unit Tests

Test individual functions, methods, and classes in isolation.

**Location**: `test/services/`, `test/model/`, `test/providers/`

**Examples**:
- `ai_service_test.dart` - Tests AIService methods
- `model_manager_test.dart` - Tests ModelManager functionality
- `ai_message_test.dart` - Tests AIMessage model

### 2. Widget Tests

Test individual widgets and their interactions.

**Location**: `test/features/`

**Examples**:
- `chat_page_test.dart` - Tests ChatPage widget
- `message_bubble_test.dart` - Tests MessageBubble widget
- `model_selection_page_test.dart` - Tests ModelSelectionPage widget

### 3. Integration Tests

Test complete workflows and app behavior.

**Location**: `integration_test/`

**Examples**:
- `app_test.dart` - Tests end-to-end workflows

See `integration_test/README.md` for more details.

## Test Coverage

Current test coverage includes:

- ✅ AI Service layer
- ✅ Model Manager
- ✅ Chat Controller
- ✅ Data Models (AIMessage, AIModelInfo, AIException)
- ✅ Providers (AI providers)
- ✅ Chat UI widgets
- ✅ Model Selection UI
- ✅ Localization

### Viewing Coverage Report

After running tests with coverage:

```bash
# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

## Writing Tests

### Test Naming Convention

- Test files should end with `_test.dart`
- Test names should be descriptive and follow the pattern: `should [expected behavior] when [condition]`

### Example Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureName', () {
    setUp(() {
      // Setup code
    });

    tearDown(() {
      // Cleanup code
    });

    test('should do something when condition is met', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = functionUnderTest(input);
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

### Widget Test Example

```dart
testWidgets('should display message', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    MaterialApp(home: MyWidget()),
  );

  // Act
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Mocking

For tests that require mocking:

- Use `mockito` for creating mocks
- Use `ProviderScope` with overrides for Riverpod providers
- Use `SharedPreferences.setMockInitialValues()` for SharedPreferences

## Skipped Tests

Some tests are marked with `skip` because they require:
- Platform channels (Android/iOS specific)
- File system access
- Network connectivity
- Actual AI model files

These tests should be run as integration tests on actual devices.

## Continuous Integration

Tests are automatically run on:
- Pull requests
- Commits to main branch
- Release builds

## Troubleshooting

### Tests Fail with "Platform channels not available"

Some tests require platform-specific functionality. These are marked with `skip` and should be run as integration tests.

### Tests Fail with "No such file or directory"

Ensure you're running tests from the project root directory.

### Widget Tests Fail with Localization Errors

Make sure to include localization delegates in your test widget:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: YourWidget(),
)
```

## Best Practices

1. **Keep tests focused**: Each test should test one thing
2. **Use descriptive names**: Test names should clearly describe what they test
3. **Arrange-Act-Assert**: Follow the AAA pattern
4. **Clean up**: Use `tearDown` to clean up resources
5. **Mock external dependencies**: Don't rely on network, file system, etc.
6. **Test edge cases**: Include tests for error conditions and edge cases
7. **Keep tests fast**: Unit tests should run in milliseconds
8. **Maintain test coverage**: Aim for >80% coverage for critical code

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)
