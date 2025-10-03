import 'package:pokifairy/shared/data/preferences_keys.dart';
import 'package:pokifairy/shared/data/prefs_service.dart';

/// Handles data migration between different app versions.
/// 
/// This service ensures backward compatibility when the data schema changes.
class MigrationService {
  const MigrationService(this._prefsService);

  final PrefsService _prefsService;

  /// Performs migration if needed.
  /// 
  /// Returns `true` if migration was performed, `false` if no migration needed.
  Future<bool> migrateIfNeeded() async {
    final currentVersion = await _prefsService.loadDataVersion();
    final targetVersion = PreferencesKeys.currentDataVersion;

    if (currentVersion >= targetVersion) {
      // No migration needed
      return false;
    }

    // Perform migrations step by step
    for (var version = currentVersion + 1;
        version <= targetVersion;
        version++) {
      await _migrateToVersion(version);
    }

    // Save the new version
    await _prefsService.saveDataVersion(targetVersion);
    return true;
  }

  /// Migrates data to a specific version.
  Future<void> _migrateToVersion(int version) async {
    switch (version) {
      case 1:
        await _migrateToV1();
        break;
      // Add more cases as new versions are released
      default:
        // Unknown version, skip
        break;
    }
  }

  /// Migration to version 1: Initial AI integration.
  /// 
  /// This is the first version with AI features, so we just need to
  /// ensure the data structure is initialized properly.
  Future<void> _migrateToV1() async {
    // Check if there's any legacy data that needs conversion
    // For now, this is a no-op since v1 is the first AI version
    
    // Initialize default AI settings if needed
    final maxMessages = await _prefsService.loadMaxChatMessages();
    if (maxMessages == 100) {
      // Default value, ensure it's explicitly saved
      await _prefsService.saveMaxChatMessages(100);
    }

    // Validate chat history format
    try {
      final history = await _prefsService.loadChatHistory();
      // If we can load it successfully, it's valid
      // If not, loadChatHistory will clear corrupted data automatically
      if (history.isNotEmpty) {
        // Re-save to ensure proper format
        await _prefsService.saveChatHistory(history);
      }
    } catch (e) {
      // Corrupted data will be cleared by loadChatHistory
    }
  }

  /// Checks if migration is needed without performing it.
  Future<bool> needsMigration() async {
    final currentVersion = await _prefsService.loadDataVersion();
    final targetVersion = PreferencesKeys.currentDataVersion;
    return currentVersion < targetVersion;
  }

  /// Gets the current data version.
  Future<int> getCurrentVersion() async {
    return await _prefsService.loadDataVersion();
  }

  /// Gets the target data version.
  int getTargetVersion() {
    return PreferencesKeys.currentDataVersion;
  }

  /// Resets all data (use with caution).
  /// 
  /// This clears all stored data and resets the version to 0.
  Future<void> resetAllData() async {
    await _prefsService.clearFairy();
    await _prefsService.clearAllAiData();
    await _prefsService.saveDataVersion(0);
  }
}
