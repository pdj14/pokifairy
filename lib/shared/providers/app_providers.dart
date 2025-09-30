import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/shared/data/prefs_service.dart';
import 'package:pokifairy/shared/model/growth_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the lazily-initialized [SharedPreferences] instance.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

/// Provides the persistence service wrapping [SharedPreferences].
final prefsServiceProvider = FutureProvider<PrefsService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return PrefsService(prefs);
});

/// Supplies the shared growth rules used across the UI.
final growthRulesProvider = Provider<FairyGrowthRules>((ref) {
  return const FairyGrowthRules();
});
