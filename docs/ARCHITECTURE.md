# PokiFairy Architecture Documentation

## Overview

PokiFairy is built using a feature-based architecture with clean separation of concerns. The app combines Flutter's reactive UI framework with Riverpod for state management and integrates on-device AI capabilities through FFI (Foreign Function Interface).

## Architecture Principles

1. **Feature-Based Organization**: Code organized by features, not layers
2. **Unidirectional Data Flow**: State flows down, events flow up
3. **Dependency Injection**: Riverpod providers for loose coupling
4. **Separation of Concerns**: Clear boundaries between UI, business logic, and data
5. **Testability**: All components designed for easy testing

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Home   │  │   Chat   │  │  Model   │  │ Settings │   │
│  │   Page   │  │   Page   │  │Selection │  │   Page   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│         ↓              ↓              ↓              ↓       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Riverpod Providers                      │  │
│  │  • FairyController  • ChatController                 │  │
│  │  • AIServiceProvider • ModelManagerProvider          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Business Logic                       │  │
│  │  • FairyService    • AIService                        │  │
│  │  • StorageService  • ModelManager                     │  │
│  │  • PermissionService                                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Fairy   │  │    AI    │  │  Chat    │  │  Model   │   │
│  │  Model   │  │  Message │  │ History  │  │   Info   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    GGUF      │  │     FFI      │  │   Storage    │     │
│  │   Engine     │  │   Bindings   │  │   Service    │     │
│  │ (llama.cpp)  │  │  (Dart↔C++)  │  │(SharedPrefs) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer
- **Responsibility**: UI rendering and user interaction
- **Components**: Pages, Widgets, Screens
- **Dependencies**: Application Layer (via Providers)
- **Rules**:
  - No business logic
  - Stateless when possible
  - Consumes providers for state
  - Emits user events to controllers

### 2. Application Layer
- **Responsibility**: State management and coordination
- **Components**: Riverpod Providers, Controllers, Notifiers
- **Dependencies**: Domain Layer, Infrastructure Layer
- **Rules**:
  - Manages application state
  - Coordinates between services
  - Handles user actions
  - No UI code

### 3. Domain Layer
- **Responsibility**: Business entities and rules
- **Components**: Models, Entities, Value Objects
- **Dependencies**: None (pure Dart)
- **Rules**:
  - Framework-agnostic
  - Immutable data structures
  - Business validation logic
  - No external dependencies

### 4. Infrastructure Layer
- **Responsibility**: External integrations and I/O
- **Components**: Services, Repositories, APIs
- **Dependencies**: Platform-specific libraries
- **Rules**:
  - Implements interfaces from domain
  - Handles platform-specific code
  - Manages external resources
  - Error handling and logging

## Folder Structure

```
lib/
├── app/                          # Application configuration
│   ├── app_router.dart           # GoRouter navigation setup
│   └── theme.dart                # Material theme definitions
│
├── features/                     # Feature modules (vertical slices)
│   ├── home/                     # Home screen feature
│   │   ├── home_page.dart        # Main home UI
│   │   └── widgets/              # Home-specific widgets
│   │
│   ├── chat/                     # AI chat feature
│   │   ├── chat_page.dart        # Chat UI
│   │   ├── providers/            # Chat state management
│   │   │   └── chat_providers.dart
│   │   └── widgets/              # Chat-specific widgets
│   │       ├── message_bubble.dart
│   │       ├── chat_input.dart
│   │       └── typing_indicator.dart
│   │
│   ├── ai_model/                 # AI model management feature
│   │   ├── model_selection_page.dart
│   │   ├── model_debug_page.dart
│   │   └── widgets/
│   │       └── model_card.dart
│   │
│   ├── care/                     # Fairy care feature
│   ├── journal/                  # Journal feature
│   ├── settings/                 # Settings feature
│   ├── onboarding/               # Onboarding feature
│   └── landing/                  # Landing feature
│
├── shared/                       # Shared resources (horizontal slices)
│   ├── data/                     # Data layer
│   │   ├── prefs_service.dart    # SharedPreferences wrapper
│   │   ├── migration_service.dart # Data migration
│   │   └── preferences_keys.dart  # Preference key constants
│   │
│   ├── model/                    # Domain models
│   │   ├── fairy_model.dart      # Fairy entity
│   │   ├── ai_message.dart       # Chat message entity
│   │   ├── ai_model_info.dart    # Model metadata
│   │   └── ai_exception.dart     # AI error types
│   │
│   ├── providers/                # Global providers
│   │   ├── fairy_providers.dart  # Fairy state
│   │   ├── ai_providers.dart     # AI state
│   │   └── settings_providers.dart
│   │
│   ├── services/                 # Business services
│   │   ├── ai/                   # AI service layer
│   │   │   ├── ai_service.dart   # Main AI service
│   │   │   ├── gguf_loader.dart  # Model loader
│   │   │   ├── model_manager.dart # Model management
│   │   │   └── native_bindings.dart # FFI bindings
│   │   ├── permission_service.dart
│   │   └── startup_service.dart
│   │
│   ├── widgets/                  # Reusable widgets
│   │   ├── error_widget.dart
│   │   ├── loading_widget.dart
│   │   └── permission_request_dialog.dart
│   │
│   └── utils/                    # Utility functions
│       └── snackbar_helper.dart
│
├── l10n/                         # Localization
│   ├── app_en.arb                # English translations
│   └── app_ko.arb                # Korean translations
│
└── main.dart                     # Application entry point

android/
└── app/src/main/
    ├── cpp/                      # Native C++ code
    │   ├── CMakeLists.txt        # CMake build config
    │   └── native_bridge.cpp     # JNI bridge
    └── jniLibs/                  # Precompiled libraries
        └── arm64-v8a/
            └── libllama.so       # llama.cpp library

ios/
└── Runner/
    └── NativeBridge/             # Native Objective-C++ code
        ├── NativeBridge.h        # Bridge header
        └── NativeBridge.mm       # Bridge implementation
```

## Core Components

### State Management (Riverpod)

#### Provider Types

```dart
// 1. Provider - Immutable, cached values
final configProvider = Provider<AppConfig>((ref) {
  return AppConfig();
});

// 2. StateProvider - Simple mutable state
final counterProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider - Complex state with logic
final chatControllerProvider = 
  StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
    return ChatController(ref);
  });

// 4. FutureProvider - Async data loading
final aiInitProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.initialize();
});

// 5. StreamProvider - Streaming data
final aiResponseProvider = StreamProvider.family<String, String>(
  (ref, prompt) {
    final service = ref.watch(aiServiceProvider);
    return service.generateResponseStream(prompt);
  },
);
```

#### State Flow Example

```
User Action (UI)
      ↓
Controller Method
      ↓
Service Call
      ↓
State Update
      ↓
Provider Notifies
      ↓
UI Rebuilds
```

### Navigation (GoRouter)

```dart
// Route definition
enum AppRoute {
  home,
  chat,
  modelSelection,
  settings,
}

// Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/chat',
        name: AppRoute.chat.name,
        builder: (context, state) => const ChatPage(),
      ),
      // ... more routes
    ],
  );
});

// Navigation
context.go(AppRoute.chat.path);
context.push(AppRoute.modelSelection.path);
```

### AI Service Architecture

```
┌─────────────────────────────────────────────┐
│              Dart Layer                      │
│  ┌─────────────────────────────────────┐   │
│  │         AIService                    │   │
│  │  • initialize()                      │   │
│  │  • generateResponseStream()          │   │
│  │  • dispose()                         │   │
│  └─────────────────────────────────────┘   │
│                    ↓                         │
│  ┌─────────────────────────────────────┐   │
│  │      NativeBindings (FFI)            │   │
│  │  • DynamicLibrary.open()             │   │
│  │  • Function lookups                  │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    ↓ FFI
┌─────────────────────────────────────────────┐
│            Native Layer (C++)                │
│  ┌─────────────────────────────────────┐   │
│  │      llama.cpp Engine                │   │
│  │  • Model loading                     │   │
│  │  • Token generation                  │   │
│  │  • Context management                │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Data Flow Diagrams

### Chat Message Flow

```
┌──────────┐
│   User   │
└────┬─────┘
     │ 1. Types message
     ↓
┌──────────────────┐
│   ChatInput      │
│   Widget         │
└────┬─────────────┘
     │ 2. onSend callback
     ↓
┌──────────────────┐
│ ChatController   │
│ .sendMessage()   │
└────┬─────────────┘
     │ 3. Add user message to state
     │ 4. Call AIService
     ↓
┌──────────────────┐
│   AIService      │
│ .generateStream()│
└────┬─────────────┘
     │ 5. FFI call to native
     ↓
┌──────────────────┐
│  llama.cpp       │
│  (Native)        │
└────┬─────────────┘
     │ 6. Stream tokens back
     ↓
┌──────────────────┐
│ ChatController   │
│ (updates state)  │
└────┬─────────────┘
     │ 7. Notify listeners
     ↓
┌──────────────────┐
│   ChatPage       │
│   (rebuilds)     │
└────┬─────────────┘
     │ 8. Display message
     ↓
┌──────────┐
│   User   │
└──────────┘
```

### Model Selection Flow

```
┌──────────┐
│   User   │
└────┬─────┘
     │ 1. Opens model selection
     ↓
┌──────────────────────┐
│ ModelSelectionPage   │
└────┬─────────────────┘
     │ 2. Watches availableModelsProvider
     ↓
┌──────────────────────┐
│   ModelManager       │
│ .getAvailableModels()│
└────┬─────────────────┘
     │ 3. Scans file system
     │ 4. Returns model list
     ↓
┌──────────────────────┐
│ ModelSelectionPage   │
│ (displays models)    │
└────┬─────────────────┘
     │ 5. User selects model
     ↓
┌──────────────────────┐
│ selectModelProvider  │
└────┬─────────────────┘
     │ 6. Save selection
     │ 7. Reinitialize AIService
     ↓
┌──────────────────────┐
│   AIService          │
│ .reinitialize()      │
└────┬─────────────────┘
     │ 8. Load new model
     ↓
┌──────────┐
│   User   │
│ (ready)  │
└──────────┘
```

## Key Design Patterns

### 1. Repository Pattern
```dart
abstract class FairyRepository {
  Future<FairyModel?> getFairy();
  Future<void> saveFairy(FairyModel fairy);
}

class FairyRepositoryImpl implements FairyRepository {
  final PrefsService _prefs;
  
  @override
  Future<FairyModel?> getFairy() async {
    final json = await _prefs.getString('fairy');
    return json != null ? FairyModel.fromJson(jsonDecode(json)) : null;
  }
  
  @override
  Future<void> saveFairy(FairyModel fairy) async {
    await _prefs.setString('fairy', jsonEncode(fairy.toJson()));
  }
}
```

### 2. Singleton Pattern (AI Service)
```dart
class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._();
  
  AIService._(); // Private constructor
  
  // Service methods...
}
```

### 3. Observer Pattern (Riverpod)
```dart
// Provider notifies all listeners when state changes
class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController() : super([]);
  
  void addMessage(ChatMessage message) {
    state = [...state, message]; // Notifies all listeners
  }
}
```

### 4. Factory Pattern (Model Creation)
```dart
class ChatMessage {
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

### 5. Strategy Pattern (Platform-Specific Code)
```dart
abstract class NativeBridge {
  Future<bool> initializeModel(String path);
}

class AndroidNativeBridge implements NativeBridge {
  @override
  Future<bool> initializeModel(String path) {
    // Android-specific implementation
  }
}

class IOSNativeBridge implements NativeBridge {
  @override
  Future<bool> initializeModel(String path) {
    // iOS-specific implementation
  }
}
```

## Performance Optimizations

### 1. Lazy Loading
- AI models loaded only when needed
- Images loaded on-demand
- Routes loaded lazily

### 2. Memoization
```dart
// Riverpod automatically caches provider results
final expensiveComputationProvider = Provider((ref) {
  // Only computed once, then cached
  return performExpensiveComputation();
});
```

### 3. ListView.builder
```dart
// Efficient list rendering - only visible items built
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    return MessageBubble(message: messages[index]);
  },
);
```

### 4. Const Constructors
```dart
// Prevents unnecessary rebuilds
const Text('Hello');
const Icon(Icons.chat);
```

### 5. Isolates (Future Enhancement)
```dart
// Heavy computation in background isolate
Future<void> loadModelInBackground() async {
  await Isolate.spawn(_loadModel, sendPort);
}
```

## Security Considerations

### 1. Data Privacy
- All AI processing on-device
- No network calls for AI inference
- Chat history stored locally only

### 2. Input Validation
```dart
String sanitizeInput(String input) {
  return input
    .trim()
    .substring(0, min(input.length, 1000)); // Max length
}
```

### 3. Permission Handling
```dart
// Request permissions before accessing files
final status = await Permission.storage.request();
if (!status.isGranted) {
  // Handle denial
}
```

### 4. Error Boundaries
```dart
// Catch and handle errors gracefully
try {
  await aiService.initialize();
} on AIException catch (e) {
  // Show user-friendly error
} catch (e) {
  // Log unexpected errors
}
```

## Testing Strategy

### 1. Unit Tests
- Test business logic in isolation
- Mock dependencies with Riverpod
- Test data models and utilities

```dart
test('ChatController adds message', () {
  final container = ProviderContainer();
  final controller = container.read(chatControllerProvider.notifier);
  
  controller.addMessage(testMessage);
  
  expect(container.read(chatControllerProvider), contains(testMessage));
});
```

### 2. Widget Tests
- Test UI components
- Verify user interactions
- Test navigation flows

```dart
testWidgets('ChatPage displays messages', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: ChatPage())),
  );
  
  expect(find.byType(MessageBubble), findsWidgets);
});
```

### 3. Integration Tests
- Test complete user workflows
- Verify feature integration
- Test on real devices

```dart
testWidgets('Complete chat workflow', (tester) async {
  // 1. Launch app
  // 2. Navigate to chat
  // 3. Send message
  // 4. Verify response
});
```

## Deployment Architecture

### Android
```
APK/AAB Structure:
├── lib/
│   ├── arm64-v8a/
│   │   └── libllama.so
│   └── armeabi-v7a/
│       └── libllama.so
├── assets/
│   └── flutter_assets/
└── classes.dex
```

### iOS
```
IPA Structure:
├── Payload/
│   └── PokiFairy.app/
│       ├── Frameworks/
│       │   └── Flutter.framework
│       ├── NativeBridge.framework
│       └── Assets.car
```

## Scalability Considerations

### Horizontal Scaling
- Feature modules can be developed independently
- New features added without affecting existing code
- Team members can work on different features simultaneously

### Vertical Scaling
- Services can be optimized independently
- AI models can be swapped without UI changes
- Storage layer can be migrated (SharedPreferences → Hive)

### Future Enhancements
- Plugin architecture for custom AI models
- Cloud sync (optional, encrypted)
- Multi-user support
- Advanced RAG capabilities

## Monitoring and Debugging

### Debug Tools
1. **Model Debug Page**: View AI model info and status
2. **Flutter DevTools**: Performance profiling
3. **Riverpod Inspector**: State debugging
4. **Native Logs**: FFI and llama.cpp logs

### Error Tracking
```dart
// Centralized error handling
void handleError(Object error, StackTrace stack) {
  // Log to console
  debugPrint('Error: $error');
  
  // Show user-friendly message
  showErrorSnackbar(context, error);
  
  // Report to analytics (future)
  // analytics.logError(error, stack);
}
```

## Conclusion

PokiFairy's architecture is designed for:
- **Maintainability**: Clear separation of concerns
- **Testability**: All components easily testable
- **Scalability**: Easy to add new features
- **Performance**: Optimized for mobile devices
- **Privacy**: On-device processing

The feature-based structure combined with Riverpod's reactive state management provides a solid foundation for building a complex, performant mobile application with AI capabilities.

---

For more information, see:
- [Project Structure](../PROJECT_STRUCTURE.md)
- [State Management Implementation](../STATE_MANAGEMENT_IMPLEMENTATION.md)
- [Performance Optimizations](../PERFORMANCE_OPTIMIZATIONS.md)
