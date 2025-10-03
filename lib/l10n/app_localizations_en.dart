// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PokiFairy';

  @override
  String get gateLoading => 'Bringing your fairy home...';

  @override
  String get gateError => 'We could not wake the fairy.';

  @override
  String get retryButton => 'Retry';

  @override
  String get setupTitle => 'Name Your Fairy';

  @override
  String get setupDescription => 'Give your pocket fairy a name.';

  @override
  String get setupNameLabel => 'Fairy name';

  @override
  String get setupNameHint => 'Example: Lumi';

  @override
  String get setupValidationEmpty => 'Please enter a name.';

  @override
  String get setupValidationTooLong => 'Name must be 12 characters or fewer.';

  @override
  String get setupCreateButton => 'Create Fairy';

  @override
  String get speciesSpirit => 'Spirit';

  @override
  String get speciesElf => 'Elf';

  @override
  String get speciesHumanlike => 'Humanlike';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String homeTodayGreeting(String name) {
    return 'Sharing today with $name';
  }

  @override
  String homeLevelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get homeActionSectionTitle => 'Fairy Care';

  @override
  String get homeActionPrompt => 'How would you like to care for your fairy?';

  @override
  String homeAffectionLabel(int count) {
    return 'Affection: $count';
  }

  @override
  String homeLastInteraction(String timestamp) {
    return 'Last bonding time: $timestamp';
  }

  @override
  String get homeLastInteractionNever => 'No bonding moments yet.';

  @override
  String get homeResetTooltip => 'Reset fairy';

  @override
  String get homeQuickLinksTitle => 'Quick links';

  @override
  String get homeAiChatButton => 'Chat with AI';

  @override
  String get actionFeed => 'Share a snack';

  @override
  String get actionPlay => 'Play together';

  @override
  String get actionRest => 'Let sleep';

  @override
  String get dialogActionResultTitle => 'Fairy\'s response';

  @override
  String dialogActionResultMessageFeed(String name) {
    return '$name enjoyed the snack!';
  }

  @override
  String dialogActionResultMessagePlay(String name) {
    return '$name had so much fun!';
  }

  @override
  String dialogActionResultMessageRest(String name) {
    return '$name is feeling refreshed.';
  }

  @override
  String get dialogButtonOk => 'OK';

  @override
  String get dialogButtonCancel => 'Cancel';

  @override
  String get statCardTitle => 'Fairy stats';

  @override
  String get statMoodLabel => 'Mood';

  @override
  String get statHungerLabel => 'Hunger';

  @override
  String get statEnergyLabel => 'Energy';

  @override
  String statExpLabel(int current, int goal) {
    return 'Experience $current/$goal';
  }

  @override
  String statLastTickLabel(String timestamp) {
    return 'Last update: $timestamp';
  }

  @override
  String get landingEmptyTitle => 'No fairy has hatched yet';

  @override
  String get landingEmptyDescription =>
      'Create your first fairy and welcome a new pocket companion.';

  @override
  String get landingCreateButton => 'Start creating a fairy';

  @override
  String get landingExistingTitle => 'Your fairy';

  @override
  String get landingOpenButton => 'Jump in and play';

  @override
  String get landingDeleteButton => 'Remove fairy';

  @override
  String get landingDeleteDialogTitle => 'Reset your fairy?';

  @override
  String get landingDeleteDialogMessage =>
      'All growth progress will disappear after resetting.';

  @override
  String get landingDeletedMessage =>
      'Your fairy has been released. Create a new friend anytime!';

  @override
  String get chatTitle => 'Chat with Fairy';

  @override
  String get chatEmptyMessage => 'Start a conversation with your fairy!';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get chatEmptyHint => 'Start a conversation with AI';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all chat history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get retry => 'Retry';

  @override
  String get aiThinking => 'Thinking...';

  @override
  String get modelSelectionTitle => 'Select AI Model';

  @override
  String get modelSelectionDescription => 'Choose an AI model to use';

  @override
  String get noModelsFound => 'No models available';

  @override
  String get noModelsDescription =>
      'Please add GGUF model files to the AiModels folder';

  @override
  String get currentModel => 'Current Model';

  @override
  String get selectModel => 'Select';

  @override
  String get modelSelected => 'Model selected successfully';

  @override
  String get modelSelectionFailed => 'Failed to select model';

  @override
  String get permissionRequired => 'Storage permission required';

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get refreshModels => 'Refresh';

  @override
  String get modelDebugTitle => 'AI Debug Info';

  @override
  String get debugRefresh => 'Refresh';

  @override
  String get debugInitStatus => 'AI Initialization Status';

  @override
  String get debugModelInfo => 'Current Model Info';

  @override
  String get debugFFIStatus => 'FFI Connection Status';

  @override
  String get debugSystemInfo => 'System Information';

  @override
  String get debugEngineStatus => 'Inference Engine Status';

  @override
  String get debugLogs => 'Debug Logs';

  @override
  String get copyLogs => 'Copy Logs';

  @override
  String get logsCopied => 'Logs copied to clipboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAiSection => 'AI Settings';

  @override
  String get settingsModelSelection => 'Select AI Model';

  @override
  String get settingsModelSelectionDescription => 'Choose an AI model to use';

  @override
  String get settingsModelDebug => 'AI Debug Info';

  @override
  String get settingsModelDebugDescription =>
      'View AI model status and debug information';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAbout => 'About App';

  @override
  String get settingsAboutDescription =>
      'PokiFairy combines a pocket fairy companion with an AI assistant.';

  @override
  String get errorModelNotFound =>
      'No AI model available. Please download a model.';

  @override
  String get errorModelLoadFailed =>
      'Failed to load AI model. Please check the model file.';

  @override
  String get errorInference =>
      'Error occurred while generating AI response. Please try again.';

  @override
  String get errorPermissionDenied =>
      'Storage permission required. Please allow permission in settings.';

  @override
  String get errorInsufficientMemory =>
      'Insufficient memory. Please close other apps and try again.';

  @override
  String get errorNetwork => 'Please check your network connection.';

  @override
  String get errorUnknown => 'An unknown error occurred.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get permissionDialogTitle => 'Permission Required';

  @override
  String get permissionDialogMessage =>
      'Storage permission is required to access AI models. Please allow permission.';

  @override
  String get permissionDialogCancel => 'Cancel';

  @override
  String get permissionDialogAllow => 'Allow Permission';

  @override
  String get permissionSettingsTitle => 'Permission Settings Required';

  @override
  String get permissionSettingsMessage =>
      'Permission was denied. Please allow permission in settings.';

  @override
  String get sendMessage => 'Send';

  @override
  String get noModelTitle => 'No AI Model';

  @override
  String get noModelDescription =>
      'Please select a model first to chat with AI.';

  @override
  String get goToModelSelection => 'Select Model';
}
