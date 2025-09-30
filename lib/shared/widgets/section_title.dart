import 'package:flutter/material.dart';

/// Displays a consistent heading for grouped content sections.
class SectionTitle extends StatelessWidget {
  /// Creates a [SectionTitle] with optional [trailing] widget.
  const SectionTitle({super.key, required this.text, this.trailing});

  /// Text displayed as the section heading.
  final String text;

  /// Widget rendered on the trailing edge, typically an action.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
