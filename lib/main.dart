import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/app/app_router.dart';
import 'package:pokifairy/app/theme.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/providers/fairy_providers.dart';

/// Entry point for the PokiFairy application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PokifairyApp()));
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(fairyControllerProvider.notifier).tickNow();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
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
