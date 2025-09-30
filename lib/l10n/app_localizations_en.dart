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
}
