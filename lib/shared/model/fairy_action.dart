import 'package:flutter/material.dart';

/// Enumerates high-level care actions available for a fairy.
enum FairyAction {
  /// Feeding the fairy a pastel snack.
  feed,

  /// Encouraging the fairy to dance and play.
  play,

  /// Allowing the fairy to rest peacefully.
  sleep,
}

/// Maps [FairyAction] values to shared metadata.
extension FairyActionX on FairyAction {
  /// Localization key for the button label.
  String get labelKey => switch (this) {
    FairyAction.feed => 'actionFeed',
    FairyAction.play => 'actionPlay',
    FairyAction.sleep => 'actionRest',
  };

  /// Localization key for the toast/dialog message.
  String get messageKey => switch (this) {
    FairyAction.feed => 'dialogActionResultMessageFeed',
    FairyAction.play => 'dialogActionResultMessagePlay',
    FairyAction.sleep => 'dialogActionResultMessageRest',
  };

  /// Localization key for the descriptive copy.
  String get descriptionKey => switch (this) {
    FairyAction.feed => 'careActionFeedDescription',
    FairyAction.play => 'careActionPlayDescription',
    FairyAction.sleep => 'careActionSleepDescription',
  };

  /// Icon used when rendering the action.
  IconData get icon => switch (this) {
    FairyAction.feed => Icons.restaurant_rounded,
    FairyAction.play => Icons.celebration_rounded,
    FairyAction.sleep => Icons.bedtime_rounded,
  };
}
