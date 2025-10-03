# PokiFairy Project Structure

This document describes the integrated project structure combining PokiFairy's companion features with OurSecretBase's OnDevice AI capabilities.

## Overview

PokiFairy is a Flutter application that combines:
- **Pocket Fairy Companion** - Original PokiFairy features for fairy care and interaction
- **OnDevice AI Chat** - Integrated AI capabilities using GGUF/llama.cpp from OurSecretBase

## Technology Stack

- **Flutter**: 3.9+
- **Dart**: 3.9+
- **State Management**: Riverpod 3.0
- **Routing**: GoRouter 16.2
- **AI Engine**: GGUF/llama.cpp (OnDevice)
- **Localization**: flutter_localizations (Korean/English)

## Folder Structure

```
lib/
├── app/                          # Application-level configuration
│   ├── app_router.dart          # GoRouter configuration
│   └── theme.dart               # App theme and styling
│
├── features/                     # Feature-based modules
│   ├── ai_model/                # AI model management (NEW)
│   │   ├── model_selection_page.dart
│   │   ├── model_debug_page.dart
│   │   └── widgets/
│   │       ├── model_card.dart
│   │       └── download_progress.dart
│   │
│   ├── chat/                    # AI chat feature (ENHANCED)
│   │   ├── chat_page.dart
│   │   ├── providers/
│   │   │   └── chat_providers.dart
│   │   └── widgets/
│   │       ├── message_bubble.dart
│   │       ├── chat_input.dart
│   │       └── typing_indicator.dart
│   │
│   ├── home/                    # Home screen
│   ├── care/                    # Fairy care features
│   ├── journal/                 # Journal features
│   ├── settings/                # Settings
│   ├── onboarding/              # Onboarding flow
│   └── landing/                 # Landing page
│
├── shared/                      # Shared resources
│   ├── data/                    # Data layer
│   │   └── prefs_service.dart
│   │
│   ├── model/                   # Data models
│   │   ├── fairy.dart
│   │   ├── chat_message.dart
│   │   ├── ai_message.dart      # (TO BE ADDED)
│   │   └── ai_model_info.dart   # (TO BE ADDED)
│   │
│   ├── providers/               # Riverpod providers
│   │   ├── app_providers.dart
│   │   ├── fairy_providers.dart
│   │   ├── chat_providers.dart
│   │   └── ai_providers.dart    # (TO BE ADDED)
│   │
│   ├── services/                # Business logic services
│   │   ├── ai/                  # AI services (NEW)
│   │   │   ├── ai_service.dart
│   │   │   ├── gguf_loader.dart
│   │   │   ├── model_manager.dart
│   │   │   ├── native_bindings.dart
│   │   │   └── rag/
│   │   └── storage/             # Storage services (NEW)
│   │       └── storage_service.dart
│   │
│   ├── widgets/                 # Shared widgets
│   └── utils/                   # Utilities
│
├── l10n/                        # Localization
│   ├── app_en.arb
│   └── app_ko.arb
│
└── main.dart                    # App entry point
```

## Native Code Structure

```
android/
└── app/src/main/
    ├── cpp/                     # Native AI engine (TO BE ADDED)
    │   ├── CMakeLists.txt
    │   └── native_bridge.cpp
    └── jniLibs/                 # Native libraries (TO BE ADDED)
        └── arm64-v8a/
            └── libllama.so

ios/
└── Runner/
    └── NativeBridge/            # iOS FFI bridge (TO BE ADDED)
        ├── NativeBridge.h
        └── NativeBridge.mm
```

## Key Design Patterns

### Feature-Based Architecture
Each feature is self-contained with its own pages, widgets, and providers.

### Riverpod State Management
- Providers for dependency injection
- StateNotifier for complex state
- FutureProvider for async operations
- StreamProvider for real-time data

### GoRouter Navigation
- Type-safe routing
- Deep linking support
- Declarative navigation

## Integration Status

### ✅ Completed
- Base project structure (PokiFairy)
- Feature folders created
- AI service folders created
- Documentation structure

### 🔄 In Progress
- Task 1: Project initial setup and structure

### ⏳ Pending
- Dependency integration
- AI service file migration
- Native bindings setup
- UI implementation
- Testing

## Development Guidelines

1. **Feature Isolation**: Keep features independent and self-contained
2. **Shared Resources**: Use shared/ for cross-feature code
3. **Riverpod First**: Use Riverpod for all state management
4. **Type Safety**: Leverage Dart's type system
5. **Localization**: Add all user-facing strings to ARB files
6. **Testing**: Write tests for business logic and critical UI

## Next Steps

1. Integrate dependencies from both projects (Task 2)
2. Copy AI service files from OurSecretBase (Task 3)
3. Implement Riverpod providers for AI services (Task 4)
4. Set up native bindings (Task 5)
5. Continue with remaining tasks...

## References

- [Design Document](.kiro/specs/project-merge/design.md)
- [Requirements Document](.kiro/specs/project-merge/requirements.md)
- [Implementation Tasks](.kiro/specs/project-merge/tasks.md)
