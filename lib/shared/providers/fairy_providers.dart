import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokifairy/shared/data/prefs_service.dart';
import 'package:pokifairy/shared/model/care_log_entry.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/model/growth_rules.dart';
import 'package:pokifairy/shared/providers/app_providers.dart';

export 'package:pokifairy/shared/model/fairy_action.dart';

/// Predefined pastel color options used during onboarding and settings flows.
const List<String> kFairyColorOptions = <String>[
  '#A0C3FF',
  '#F7B5CA',
  '#FFE5A0',
  '#AEE4D0',
  '#D6C5FF',
];

/// Provides the currently loaded fairy, if any.
final fairyProvider = Provider<Fairy?>((ref) {
  return ref.watch(fairyControllerProvider).asData?.value;
});

/// Provides all saved fairies.
final allFairiesProvider = FutureProvider<Map<String, Fairy>>((ref) async {
  // FairyController가 변경될 때마다 자동으로 갱신되도록 연결
  ref.watch(fairyControllerProvider);
  final prefs = await ref.watch(prefsServiceProvider.future);
  return await prefs.loadAllFairies();
});

/// Provides the list of all fairies as a list.
final fairiesListProvider = FutureProvider<List<Fairy>>((ref) async {
  // FairyController가 변경될 때마다 자동으로 갱신되도록 연결
  ref.watch(fairyControllerProvider);
  final fairiesMap = await ref.watch(allFairiesProvider.future);
  return fairiesMap.values.toList();
});

/// Drives the lifecycle of the currently active fairy.
class FairyController extends AsyncNotifier<Fairy?> {
  late PrefsService _prefs;
  late FairyGrowthRules _rules;
  final _random = Random();

  @override
  Future<Fairy?> build() async {
    _prefs = await ref.watch(prefsServiceProvider.future);
    _rules = ref.watch(growthRulesProvider);

    // Try to load active fairy first
    final activeFairyId = await _prefs.loadActiveFairyId();
    if (activeFairyId != null) {
      final allFairies = await _prefs.loadAllFairies();
      final storedFairy = allFairies[activeFairyId];
      if (storedFairy != null) {
        final now = DateTime.now();
        final lastOpened = await _prefs.loadLastOpenedAt() ?? storedFairy.lastTick;
        final delta = now.difference(lastOpened);

        final updated = _rules
            .tick(
              fairy: storedFairy.copyWith(lastTick: lastOpened),
              delta: delta,
            )
            .copyWith(lastTick: now);
        await _persist(updated);
        return updated;
      }
    }

    // Fallback to old single fairy system for backward compatibility
    final storedFairy = await _prefs.loadFairy();
    if (storedFairy != null) {
      final now = DateTime.now();
      final lastOpened = await _prefs.loadLastOpenedAt() ?? storedFairy.lastTick;
      final delta = now.difference(lastOpened);

      final updated = _rules
          .tick(
            fairy: storedFairy.copyWith(lastTick: lastOpened),
            delta: delta,
          )
          .copyWith(lastTick: now);
      await _persist(updated);
      return updated;
    }

    return null;
  }

  Future<Fairy?> createFairy({
    required String name,
    FairySpecies species = FairySpecies.spirit,
    String color = '#A0C3FF',
    int imageIndex = 0,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalizedColor = _normalizeColor(color);
    final now = DateTime.now();
    final fairy = Fairy(
      id: _generateId(),
      name: trimmed,
      species: species,
      color: normalizedColor,
      imageIndex: imageIndex,
      level: 1,
      exp: 0,
      mood: 80,
      hunger: 20,
      energy: 80,
      createdAt: now,
      lastTick: now,
    );

    state = const AsyncValue.loading();
    try {
      // Save to the new multi-fairy system
      final allFairies = await _prefs.loadAllFairies();
      allFairies[fairy.id] = fairy;
      await _prefs.saveAllFairies(allFairies);
      
      // Set as active fairy
      await _prefs.saveActiveFairyId(fairy.id);
      
      state = AsyncValue.data(fairy);
      return fairy;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<Fairy?> updateFairy({
    String? name,
    FairySpecies? species,
    String? color,
  }) async {
    final current = state.asData?.value;
    if (current == null) {
      return null;
    }

    var updatedName = current.name;
    if (name != null) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) {
        updatedName = trimmed;
      }
    }

    final updatedFairy = current.copyWith(
      name: updatedName,
      species: species ?? current.species,
      color: color != null ? _normalizeColor(color) : current.color,
    );

    state = AsyncValue.data(updatedFairy);
    await _persist(updatedFairy);
    return updatedFairy;
  }

  Future<Fairy?> tickNow() async {
    final current = state.asData?.value;
    if (current == null) {
      return null;
    }
    final now = DateTime.now();
    final delta = now.difference(current.lastTick);
    final updated = _rules
        .tick(fairy: current, delta: delta)
        .copyWith(lastTick: now);
    state = AsyncValue.data(updated);
    await _persist(updated);
    return updated;
  }

  Future<Fairy?> feedFairy() async {
    return _applyAction((fairy) => _rules.feed(fairy));
  }

  Future<Fairy?> playFairy() async {
    return _applyAction((fairy) => _rules.play(fairy));
  }

  Future<Fairy?> sleepFairy() async {
    return _applyAction((fairy) => _rules.sleep(fairy));
  }

  Future<void> updateFairyName(String newName) async {
    await updateFairy(name: newName);
  }

  Future<void> resetFairy() async {
    state = const AsyncValue.loading();
    try {
      await _prefs.clearFairy();
      ref.read(careLogProvider.notifier).clear();
      state = const AsyncValue<Fairy?>.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Fairy?> _applyAction(Fairy Function(Fairy fairy) transform) async {
    final current = state.asData?.value;
    if (current == null) {
      return null;
    }
    final now = DateTime.now();
    final updated = transform(current).copyWith(lastTick: now);
    state = AsyncValue.data(updated);
    await _persist(updated);
    return updated;
  }

  Future<void> _persist(Fairy fairy) async {
    // Update in the multi-fairy system
    final allFairies = await _prefs.loadAllFairies();
    allFairies[fairy.id] = fairy;
    await _prefs.saveAllFairies(allFairies);
    
    // Save last opened time
    await _prefs.saveLastOpenedAt(fairy.lastTick);
  }

  /// Switches to a different fairy by ID.
  Future<void> switchToFairy(String fairyId) async {
    final allFairies = await _prefs.loadAllFairies();
    final fairy = allFairies[fairyId];
    if (fairy != null) {
      await _prefs.saveActiveFairyId(fairyId);
      state = AsyncValue.data(fairy);
    }
  }

  /// Deletes a fairy by ID.
  Future<void> deleteFairy(String fairyId) async {
    await _prefs.removeFairy(fairyId);
    
    // If we deleted the active fairy, try to load another one
    final currentActive = await _prefs.loadActiveFairyId();
    if (currentActive == fairyId) {
      final allFairies = await _prefs.loadAllFairies();
      if (allFairies.isNotEmpty) {
        final firstFairy = allFairies.values.first;
        await _prefs.saveActiveFairyId(firstFairy.id);
        state = AsyncValue.data(firstFairy);
      } else {
        state = const AsyncValue.data(null);
      }
    } else {
      // If we didn't delete the active fairy, just refresh the state
      final currentFairy = state.asData?.value;
      if (currentFairy != null) {
        state = AsyncValue.data(currentFairy);
      }
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = _random.nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
    return 'fairy_$timestamp$suffix';
  }

  String _normalizeColor(String color) {
    if (color.startsWith('#')) {
      return color.toUpperCase();
    }
    return '#${color.toUpperCase()}';
  }
}

/// Provides the singleton controller maintaining fairy state.
final fairyControllerProvider = AsyncNotifierProvider<FairyController, Fairy?>(
  FairyController.new,
);

/// Stores in-memory care action logs for the current session.
class CareLogNotifier extends Notifier<List<CareLogEntry>> {
  // TODO(hive-storage): Replace in-memory care log with Hive-backed history for journal analytics.
  @override
  List<CareLogEntry> build() => const [];

  /// Records a new [entry] keeping only the most recent 20 items.
  void record(CareLogEntry entry) {
    state = <CareLogEntry>[entry, ...state].take(20).toList(growable: false);
  }

  /// Clears all tracked log entries.
  void clear() {
    state = const [];
  }
}

/// Provider exposing the session care action log.
final careLogProvider =
    // TODO(hive-storage): Persist care logs once Hive migration lands.
    NotifierProvider<CareLogNotifier, List<CareLogEntry>>(CareLogNotifier.new);
