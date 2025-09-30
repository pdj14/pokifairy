import 'package:pokifairy/shared/model/fairy_action.dart';

/// Represents a single care action performed by the player.
class CareLogEntry {
  /// Creates a [CareLogEntry] with the action metadata.
  CareLogEntry({
    required this.action,
    required this.timestamp,
    required this.message,
  });

  /// Action that was performed.
  final FairyAction action;

  /// Moment the action was executed.
  final DateTime timestamp;

  /// Localized message summarizing the action.
  final String message;
}
