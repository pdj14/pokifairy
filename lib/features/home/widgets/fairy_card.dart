import 'package:flutter/material.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/widgets/safe_lottie.dart';

/// Displays the active fairy summary along with its visual identity.
class FairyCard extends StatelessWidget {
  /// Creates a [FairyCard] widget.
  const FairyCard({
    super.key,
    required this.fairy,
    required this.speciesLabel,
    required this.accentColor,
    this.onReset,
  });

  /// Fairy profile to display.
  final Fairy fairy;

  /// Localized label describing the fairy species.
  final String speciesLabel;

  /// Accent color chosen during onboarding/settings.
  final Color accentColor;

  /// Callback triggered when the reset action is requested.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        accentColor.withValues(alpha: 0.25),
        accentColor.withValues(alpha: 0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fairy.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$speciesLabel 쨌 Lv.${fairy.level}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.homeResetTooltip,
                        onPressed: onReset,
                        icon: const Icon(Icons.restart_alt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Badge(color: accentColor, label: speciesLabel),
                      _Badge(
                        color: accentColor,
                        label: fairy.color.toUpperCase(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SafeLottie(
                      asset: 'assets/lottie/placeholder.json',
                      fallback: Icon(
                        Icons.auto_awesome,
                        size: 96,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      label: Text(label),
    );
  }
}
