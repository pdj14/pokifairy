import 'dart:convert';

import 'package:pokifairy/shared/data/preferences_keys.dart';
import 'package:pokifairy/shared/model/ai_message.dart';
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

  // ========== AI-related methods ==========

  /// Saves the selected AI model path.
  Future<void> saveSelectedModelPath(String modelPath) async {
    await _prefs.setString(PreferencesKeys.selectedModelPath, modelPath);
  }

  /// Loads the selected AI model path.
  Future<String?> loadSelectedModelPath() async {
    return _prefs.getString(PreferencesKeys.selectedModelPath);
  }

  /// Clears the selected AI model path.
  Future<void> clearSelectedModelPath() async {
    await _prefs.remove(PreferencesKeys.selectedModelPath);
  }

  /// Saves chat history to storage.
  /// 
  /// [messages] - List of AI messages to save
  /// [maxMessages] - Maximum number of messages to keep (default: 100)
  Future<void> saveChatHistory(
    List<AIMessage> messages, {
    int maxMessages = 100,
  }) async {
    // Trim to max messages if needed
    final messagesToSave = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;

    final jsonList = messagesToSave.map((msg) => msg.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    await _prefs.setString(PreferencesKeys.chatHistory, encoded);
  }

  /// Loads chat history from storage.
  /// 
  /// Returns an empty list if no history exists or if parsing fails.
  Future<List<AIMessage>> loadChatHistory() async {
    try {
      final raw = _prefs.getString(PreferencesKeys.chatHistory);
      if (raw == null) {
        return [];
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((json) => AIMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list and clear corrupted data
      await clearChatHistory();
      return [];
    }
  }

  /// Clears all chat history.
  Future<void> clearChatHistory() async {
    await _prefs.remove(PreferencesKeys.chatHistory);
  }

  /// Saves the maximum number of chat messages to keep.
  Future<void> saveMaxChatMessages(int maxMessages) async {
    await _prefs.setInt(PreferencesKeys.maxChatMessages, maxMessages);
  }

  /// Loads the maximum number of chat messages to keep.
  /// 
  /// Returns 100 as default if not set.
  Future<int> loadMaxChatMessages() async {
    return _prefs.getInt(PreferencesKeys.maxChatMessages) ?? 100;
  }

  /// Saves the last AI initialization timestamp.
  Future<void> saveLastAiInitAt(DateTime timestamp) async {
    await _prefs.setString(
      PreferencesKeys.lastAiInitAt,
      timestamp.toIso8601String(),
    );
  }

  /// Loads the last AI initialization timestamp.
  Future<DateTime?> loadLastAiInitAt() async {
    final raw = _prefs.getString(PreferencesKeys.lastAiInitAt);
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  /// Saves AI configuration as JSON.
  Future<void> saveAiConfig(Map<String, dynamic> config) async {
    final encoded = jsonEncode(config);
    await _prefs.setString(PreferencesKeys.aiConfig, encoded);
  }

  /// Loads AI configuration from storage.
  Future<Map<String, dynamic>?> loadAiConfig() async {
    try {
      final raw = _prefs.getString(PreferencesKeys.aiConfig);
      if (raw == null) {
        return null;
      }
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails, return null and clear corrupted data
      await _prefs.remove(PreferencesKeys.aiConfig);
      return null;
    }
  }

  /// Clears all AI-related data.
  Future<void> clearAllAiData() async {
    await Future.wait([
      clearSelectedModelPath(),
      clearChatHistory(),
      _prefs.remove(PreferencesKeys.maxChatMessages),
      _prefs.remove(PreferencesKeys.lastAiInitAt),
      _prefs.remove(PreferencesKeys.aiConfig),
    ]);
  }

  // ========== Data versioning and migration ==========

  /// Saves the current data version.
  Future<void> saveDataVersion(int version) async {
    await _prefs.setInt(PreferencesKeys.dataVersion, version);
  }

  /// Loads the current data version.
  /// 
  /// Returns 0 if no version is set (first install).
  Future<int> loadDataVersion() async {
    return _prefs.getInt(PreferencesKeys.dataVersion) ?? 0;
  }
}
