# State Management and Persistence Implementation

## Overview

This document describes the implementation of Task 13: 상태 관리 및 영속성 (State Management and Persistence) for the PokiFairy + AI integration project.

## Implemented Components

### 1. PreferencesKeys (Task 13.2)

**File:** `lib/shared/data/preferences_keys.dart`

Centralized definition of all SharedPreferences keys used throughout the application:

- **Fairy-related keys** (existing):
  - `fairyJson`, `fairiesJson`, `activeFairyId`, `lastOpenedAt`

- **AI-related keys** (new):
  - `selectedModelPath` - Stores the file path of the currently selected AI model
  - `chatHistory` - Stores the chat history as a JSON array
  - `maxChatMessages` - Stores the maximum number of messages to keep
  - `lastAiInitAt` - Stores the last AI initialization timestamp
  - `aiConfig` - Stores AI service configuration as JSON

- **Data versioning**:
  - `dataVersion` - Current data schema version for migration
  - `currentDataVersion` - Constant set to 1

### 2. StorageService Extension (Task 13.1)

**File:** `lib/shared/data/prefs_service.dart`

Extended the existing `PrefsService` with AI-related methods:

#### AI Model Management
- `saveSelectedModelPath(String)` - Save selected AI model path
- `loadSelectedModelPath()` - Load selected AI model path
- `clearSelectedModelPath()` - Clear selected AI model path

#### Chat History Management
- `saveChatHistory(List<AIMessage>, {int maxMessages})` - Save chat history with automatic trimming
- `loadChatHistory()` - Load chat history with error recovery
- `clearChatHistory()` - Clear all chat history

#### AI Configuration
- `saveMaxChatMessages(int)` - Save max message limit
- `loadMaxChatMessages()` - Load max message limit (default: 100)
- `saveLastAiInitAt(DateTime)` - Save last AI initialization time
- `loadLastAiInitAt()` - Load last AI initialization time
- `saveAiConfig(Map)` - Save AI configuration as JSON
- `loadAiConfig()` - Load AI configuration with error recovery
- `clearAllAiData()` - Clear all AI-related data

#### Data Versioning
- `saveDataVersion(int)` - Save current data version
- `loadDataVersion()` - Load current data version (default: 0 for first install)

### 3. Data Migration Logic (Task 13.5)

**File:** `lib/shared/data/migration_service.dart`

Handles data migration between different app versions:

#### Key Methods
- `migrateIfNeeded()` - Performs migration if needed, returns true if migration was performed
- `needsMigration()` - Checks if migration is needed without performing it
- `getCurrentVersion()` - Gets the current data version
- `getTargetVersion()` - Gets the target data version
- `resetAllData()` - Resets all data (use with caution)

#### Migration Strategy
- Step-by-step migration from current version to target version
- Version 1 migration: Initial AI integration setup
- Validates and repairs corrupted data
- Ensures backward compatibility

### 4. App Startup Configuration Loading (Task 13.3)

**File:** `lib/shared/services/startup_service.dart`

Coordinates app startup initialization:

#### StartupService Methods
- `initialize(WidgetRef)` - Performs all startup tasks:
  1. Data migration
  2. Load saved AI model path
  3. Verify model still exists
  4. Initialize AI service with saved model
  5. Update providers
  
- `loadChatHistory(WidgetRef)` - Loads chat history (for future use)
- `isFirstLaunch()` - Checks if this is the first app launch
- `getDiagnostics()` - Gets startup diagnostics information

#### Providers
- `startupServiceProvider` - Provides StartupService instance
- `prefsServiceProvider` - Provides PrefsService instance (must be overridden)
- `migrationServiceProvider` - Provides MigrationService instance
- `appInitializationProvider` - FutureProvider for app initialization state

#### Main.dart Integration
Updated `main.dart` to:
- Initialize SharedPreferences before app starts
- Override `prefsServiceProvider` with actual instance
- Show loading screen during initialization
- Handle initialization errors gracefully

### 5. Background State Saving (Task 13.4)

**Updated Files:**
- `lib/main.dart`
- `lib/features/chat/providers/chat_providers.dart`

#### Implementation

**ChatController Updates:**
- Migrated from direct SharedPreferences to PrefsService
- Added `saveStateNow()` method for immediate state saving
- Uses PrefsService methods for all persistence operations

**App Lifecycle Management:**
- `WidgetsBindingObserver` monitors app lifecycle
- `didChangeAppLifecycleState()` detects when app goes to background
- `_saveStateOnPause()` saves all state when app is paused:
  - Fairy state (via FairyController)
  - Chat history (via ChatController)
  - Last opened timestamp

**Loading Screen:**
- Shows loading indicator during initialization
- Displays app name
- Prevents UI from showing before initialization completes

## Data Flow

### Startup Flow
```
main() 
  → Initialize SharedPreferences
  → Create PrefsService
  → Override providers
  → Start app
  → _initializeApp()
    → Run migrations
    → Load saved model
    → Initialize AI service
    → Update providers
  → Show main UI
```

### Background Save Flow
```
App goes to background
  → didChangeAppLifecycleState(paused)
  → _saveStateOnPause()
    → Save fairy state
    → Save chat history
    → Save timestamp
```

### Chat History Flow
```
ChatController.build()
  → _loadHistory()
    → PrefsService.loadChatHistory()
    → Set state

ChatController.sendMessage()
  → Add user message
  → _saveHistory()
  → Stream AI response
  → Update message
  → _trimHistory()
  → _saveHistory()
```

## Error Handling

All persistence operations include error handling:
- **Load failures**: Return default values, clear corrupted data
- **Save failures**: Log errors but don't crash app
- **Migration failures**: Continue with current version
- **Initialization failures**: App continues without AI features

## Testing Recommendations

1. **Unit Tests:**
   - PrefsService AI methods
   - MigrationService migration logic
   - StartupService initialization flow

2. **Integration Tests:**
   - Full startup sequence
   - Background state saving
   - Data migration scenarios

3. **Manual Tests:**
   - First launch experience
   - App restart with saved state
   - Background/foreground transitions
   - Model selection persistence
   - Chat history persistence

## Future Enhancements

1. **Encryption**: Add encryption for sensitive data
2. **Cloud Sync**: Optional cloud backup of settings
3. **Export/Import**: Allow users to export/import their data
4. **Advanced Migration**: More sophisticated migration strategies
5. **Performance**: Optimize large chat history handling

## Requirements Satisfied

- ✅ 9.1: AI settings saved to shared_preferences
- ✅ 9.2: Selected model info saved and auto-loaded on restart
- ✅ 9.4: State saved when app goes to background
- ✅ 9.6: Data migration with version compatibility

## Files Created/Modified

### Created:
- `lib/shared/data/preferences_keys.dart`
- `lib/shared/data/migration_service.dart`
- `lib/shared/services/startup_service.dart`
- `STATE_MANAGEMENT_IMPLEMENTATION.md`

### Modified:
- `lib/shared/data/prefs_service.dart`
- `lib/main.dart`
- `lib/features/chat/providers/chat_providers.dart`

## Conclusion

Task 13 has been successfully implemented with all subtasks completed. The app now has:
- Centralized preferences key management
- Comprehensive AI data persistence
- Automatic data migration
- Startup configuration loading
- Background state saving

The implementation follows Flutter best practices and integrates seamlessly with the existing Riverpod architecture.
