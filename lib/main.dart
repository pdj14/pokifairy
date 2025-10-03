import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/app/theme.dart';
import 'package:pokifairy/features/chat/providers/chat_providers.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/data/prefs_service.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';
import 'package:pokifairy/shared/providers/ai_providers.dart';
import 'package:pokifairy/shared/services/startup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry point for the PokiFairy application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final prefsService = PrefsService(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        // Override the prefsServiceProvider with the actual instance
        prefsServiceProvider.overrideWithValue(prefsService),
      ],
      child: const PokifairyApp(),
    ),
  );
}

/// Configures the root widget with routing, themes, and localization.
class PokifairyApp extends ConsumerStatefulWidget {
  /// Creates a new [PokifairyApp] instance.
  const PokifairyApp({super.key});

  @override
  ConsumerState<PokifairyApp> createState() => _PokifairyAppState();
}

class _PokifairyAppState extends ConsumerState<PokifairyApp>
    with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Initialize app on startup
  Future<void> _initializeApp() async {
    try {
      // Trigger app initialization (migration, model loading, etc.)
      await ref.read(appInitializationProvider.future);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Log error but continue - app can still function without AI
      debugPrint('App initialization error: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(fairyControllerProvider.notifier).tickNow();
      
      // Resume AI operations
      try {
        final aiService = ref.read(aiServiceProvider);
        aiService.setBackgroundState(false);
        debugPrint('App resumed: AI operations enabled');
      } catch (e) {
        debugPrint('Error resuming AI: $e');
      }
    } else if (state == AppLifecycleState.paused) {
      // Pause AI operations to save battery
      try {
        final aiService = ref.read(aiServiceProvider);
        aiService.setBackgroundState(true);
        debugPrint('App paused: AI operations suspended');
      } catch (e) {
        debugPrint('Error pausing AI: $e');
      }
      
      // Save state when app goes to background
      _saveStateOnPause();
    }
    super.didChangeAppLifecycleState(state);
  }
  
  @override
  void didHaveMemoryPressure() {
    // Handle memory pressure by unloading AI model if needed
    try {
      final chatController = ref.read(chatControllerProvider.notifier);
      chatController.handleLowMemory();
      debugPrint('Memory pressure detected: AI model unloaded');
    } catch (e) {
      debugPrint('Error handling memory pressure: $e');
    }
    super.didHaveMemoryPressure();
  }

  /// Save app state when going to background
  Future<void> _saveStateOnPause() async {
    try {
      final prefsService = ref.read(prefsServiceProvider);
      
      // Fairy state is automatically persisted by FairyController
      
      // Save chat history
      try {
        final chatController = ref.read(chatControllerProvider.notifier);
        await chatController.saveStateNow();
      } catch (e) {
        // Chat controller might not be initialized yet, that's okay
        debugPrint('Chat controller not initialized: $e');
      }
      
      // Save last opened timestamp
      await prefsService.saveLastOpenedAt(DateTime.now());
      
      debugPrint('App state saved successfully');
    } catch (e) {
      debugPrint('Error saving state on pause: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.lightTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'PokiFairy',
                  style: AppTheme.lightTheme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('ko'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
