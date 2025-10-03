import 'dart:convert';

import 'package:pokifairy/shared/model/fairy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistence of simple app state via [SharedPreferences].
class PrefsService {
  /// Constructs a [PrefsService] backed by [SharedPreferences].
  const PrefsService(this._prefs);

  static const String _fairyKey = 'pf_fairy_json';
  static const String _fairiesKey = 'pf_fairies_json';
  static const String _activeFairyIdKey = 'pf_active_fairy_id';
  static const String _lastOpenedKey = 'pf_last_opened_at';

  final SharedPreferences _prefs;

  /// Restores the saved [Fairy] instance or returns `null` when absent.
  Future<Fairy?> loadFairy() async {
    final raw = _prefs.getString(_fairyKey);
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    return Fairy.fromJson(decoded);
  }

  /// Persists the provided [fairy] snapshot.
  Future<void> saveFairy(Fairy fairy) async {
    final payload = jsonEncode(fairy.toJson());
    await _prefs.setString(_fairyKey, payload);
  }

  /// Removes any stored fairy profile information.
  Future<void> clearFairy() async {
    await _prefs.remove(_fairyKey);
    await _prefs.remove(_lastOpenedKey);
  }

  /// Stores the last time the application was opened.
  Future<void> saveLastOpenedAt(DateTime value) async {
    await _prefs.setString(_lastOpenedKey, value.toIso8601String());
  }

  /// Retrieves the last recorded open timestamp, if available.
  Future<DateTime?> loadLastOpenedAt() async {
    final raw = _prefs.getString(_lastOpenedKey);
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  /// Loads all saved fairies as a map of ID to Fairy.
  Future<Map<String, Fairy>> loadAllFairies() async {
    final raw = _prefs.getString(_fairiesKey);
    if (raw == null) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    final result = <String, Fairy>{};
    for (final entry in decoded.entries) {
      result[entry.key] = Fairy.fromJson(entry.value as Map<String, Object?>);
    }
    return result;
  }

  /// Saves all fairies to storage.
  Future<void> saveAllFairies(Map<String, Fairy> fairies) async {
    final encoded = <String, Object?>{};
    for (final entry in fairies.entries) {
      encoded[entry.key] = entry.value.toJson();
    }
    await _prefs.setString(_fairiesKey, jsonEncode(encoded));
  }

  /// Loads the currently active fairy ID.
  Future<String?> loadActiveFairyId() async {
    return _prefs.getString(_activeFairyIdKey);
  }

  /// Saves the currently active fairy ID.
  Future<void> saveActiveFairyId(String id) async {
    await _prefs.setString(_activeFairyIdKey, id);
  }

  /// Removes a specific fairy by ID.
  Future<void> removeFairy(String id) async {
    final fairies = await loadAllFairies();
    fairies.remove(id);
    await saveAllFairies(fairies);
    
    // If this was the active fairy, clear the active ID
    final activeId = await loadActiveFairyId();
    if (activeId == id) {
      await _prefs.remove(_activeFairyIdKey);
    }
  }
}
