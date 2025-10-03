/// Defines all SharedPreferences keys used throughout the application.
/// 
/// This centralized approach prevents key collisions and makes it easier
/// to track what data is being persisted.
class PreferencesKeys {
  PreferencesKeys._();

  // Fairy-related keys (existing)
  static const String fairyJson = 'pf_fairy_json';
  static const String fairiesJson = 'pf_fairies_json';
  static const String activeFairyId = 'pf_active_fairy_id';
  static const String lastOpenedAt = 'pf_last_opened_at';

  // AI-related keys (new)
  /// Stores the file path of the currently selected AI model
  static const String selectedModelPath = 'pf_ai_selected_model_path';
  
  /// Stores the chat history as a JSON array
  static const String chatHistory = 'pf_ai_chat_history';
  
  /// Stores the maximum number of messages to keep in history
  static const String maxChatMessages = 'pf_ai_max_chat_messages';
  
  /// Stores the last time AI service was initialized
  static const String lastAiInitAt = 'pf_ai_last_init_at';
  
  /// Stores AI service configuration as JSON
  static const String aiConfig = 'pf_ai_config';

  // Data version for migration
  /// Stores the current data schema version for migration purposes
  static const String dataVersion = 'pf_data_version';
  
  /// Current data schema version
  static const int currentDataVersion = 1;
}
