import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/shared/data/migration_service.dart';
import 'package:pokifairy/shared/data/prefs_service.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/services/ai/model_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles app startup initialization tasks.
/// 
/// This service coordinates:
/// - Data migration
/// - Loading saved settings
/// - Initializing AI service with saved model
class StartupService {
  const StartupService({
    required this.prefsService,
    required this.migrationService,
  });

  final PrefsService prefsService;
  final MigrationService migrationService;

  /// Performs all startup initialization tasks.
  /// 
  /// Returns a map with initialization results:
  /// - 'migrated': bool - whether migration was performed
  /// - 'modelLoaded': bool - whether AI model was loaded (always false now with lazy loading)
  /// - 'modelPath': String? - path of saved model (if any)
  /// 
  /// Note: AI model is no longer loaded at startup for performance.
  /// It will be lazy-loaded when first needed (e.g., when sending first chat message).
  Future<Map<String, dynamic>> initialize(Ref ref) async {
    final results = <String, dynamic>{
      'migrated': false,
      'modelLoaded': false,
      'modelPath': null,
    };

    try {
      // Step 1: Perform data migration if needed
      final migrated = await migrationService.migrateIfNeeded();
      results['migrated'] = migrated;

      // Step 2: Load saved AI model path (but don't initialize yet)
      final savedModelPath = await prefsService.loadSelectedModelPath();
      
      if (savedModelPath != null) {
        // Step 3: Verify the model still exists
        final models = await ModelManager.scanForModels();
        final modelExists = models.any((model) => model.path == savedModelPath);

        if (modelExists) {
          // Step 4: Set the model path but DON'T initialize AI service yet
          await ModelManager.setCurrentModel(savedModelPath);
          
          // Update the current model provider
          final selectedModel = models.firstWhere(
            (model) => model.path == savedModelPath,
          );
          ref.read(currentModelProvider.notifier).setModel(selectedModel);

          results['modelPath'] = savedModelPath;
          
          // Note: AI service will be initialized lazily when first chat message is sent
        } else {
          // Model no longer exists, clear the saved path
          await prefsService.clearSelectedModelPath();
        }
      }

      return results;
    } catch (e) {
      // Log error but don't crash the app
      results['error'] = e.toString();
      return results;
    }
  }

  /// Loads chat history from storage.
  Future<void> loadChatHistory(Ref ref) async {
    try {
      final history = await prefsService.loadChatHistory();
      // Chat history will be loaded by ChatController when needed
      // This method is here for future use if we need to preload
    } catch (e) {
      // Ignore errors, chat will start fresh
    }
  }

  /// Checks if this is the first app launch.
  Future<bool> isFirstLaunch() async {
    final version = await prefsService.loadDataVersion();
    return version == 0;
  }

  /// Gets startup diagnostics information.
  Future<Map<String, dynamic>> getDiagnostics() async {
    return {
      'dataVersion': await prefsService.loadDataVersion(),
      'needsMigration': await migrationService.needsMigration(),
      'hasSelectedModel': await prefsService.loadSelectedModelPath() != null,
      'hasChatHistory': (await prefsService.loadChatHistory()).isNotEmpty,
      'lastAiInit': await prefsService.loadLastAiInitAt(),
    };
  }
}

/// Provider for StartupService.
final startupServiceProvider = Provider<StartupService>((ref) {
  final prefs = ref.watch(prefsServiceProvider);
  final migration = ref.watch(migrationServiceProvider);
  return StartupService(
    prefsService: prefs,
    migrationService: migration,
  );
});

/// Provider for PrefsService.
final prefsServiceProvider = Provider<PrefsService>((ref) {
  throw UnimplementedError(
    'prefsServiceProvider must be overridden in ProviderScope',
  );
});

/// Provider for MigrationService.
final migrationServiceProvider = Provider<MigrationService>((ref) {
  final prefs = ref.watch(prefsServiceProvider);
  return MigrationService(prefs);
});

/// Provider for app initialization state.
/// 
/// This should be watched at app startup to ensure all initialization
/// tasks are completed before showing the main UI.
final appInitializationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final startupService = ref.watch(startupServiceProvider);
  return await startupService.initialize(ref);
});
