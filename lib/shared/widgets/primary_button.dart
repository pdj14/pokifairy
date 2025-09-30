import 'package:flutter/material.dart';

/// Primary filled button used across the app with semantic and tooltip hints.
class PrimaryButton extends StatelessWidget {
  /// Creates a [PrimaryButton] with the given [label] and optional [icon].
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    String? tooltip,
    String? semanticLabel,
  }) : tooltip = tooltip ?? label,
       semanticLabel = semanticLabel ?? label;

  /// Text rendered inside the button.
  final String label;

  /// Callback triggered when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional icon shown before the [label].
  final Widget? icon;

  /// Tooltip displayed on hover/long-press.
  final String tooltip;

  /// Semantic description announced to assistive technologies.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [icon!, const SizedBox(width: 8), Text(label)],
          );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: tooltip,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
