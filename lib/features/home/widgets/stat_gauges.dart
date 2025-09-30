import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokifairy/l10n/app_localizations.dart';
import 'package:pokifairy/shared/model/fairy.dart';

/// Visualizes aggregate stats such as mood, hunger, energy, and experience.
class StatGauges extends StatelessWidget {
  /// Creates a [StatGauges] widget.
  const StatGauges({super.key, required this.fairy});

  /// Fairy whose stats are rendered.
  final Fairy fairy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expGoal = fairy.level * 100;
    final expProgress = expGoal == 0 ? 0 : fairy.exp / expGoal;
    final lastTickLabel = DateFormat.yMMMd(
      l10n.localeName,
    ).add_Hm().format(fairy.lastTick);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statCardTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _StatBar(
              label: l10n.statMoodLabel,
              value: fairy.mood,
              color: Colors.pinkAccent,
            ),
            _StatBar(
              label: l10n.statHungerLabel,
              value: fairy.hunger,
              color: Colors.orangeAccent,
            ),
            _StatBar(
              label: l10n.statEnergyLabel,
              value: fairy.energy,
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(height: 12),
            Text(l10n.statExpLabel(fairy.exp, expGoal)),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: expProgress.clamp(0, 1).toDouble()),
            const SizedBox(height: 12),
            Text(l10n.statLastTickLabel(lastTickLabel)),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / 100).clamp(0, 1).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$value'),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
