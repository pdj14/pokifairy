import 'dart:math';

import 'package:pokifairy/shared/model/fairy.dart';

int _clampStat(num value) => value.clamp(0, 100).round();

/// Encapsulates lifecycle and stat rules for pocket fairies.
class FairyGrowthRules {
  // TODO(on-device-model): Allow mood and stat adjustments to be tuned by on-device inference outputs.
  /// Creates a [FairyGrowthRules] instance.
  const FairyGrowthRules();

  static const double _hungerPerMinute = 1;
  static const double _energyPerMinute = 1;
  static const double _passiveExpPerMinute = 0.3;

  /// Applies passive stat decay and growth based on elapsed [delta].
  Fairy tick({required Fairy fairy, required Duration delta}) {
    final minutes = delta.inSeconds / 60.0;
    if (minutes <= 0) {
      return fairy;
    }

    final updatedHunger = fairy.hunger + minutes * _hungerPerMinute;
    final updatedEnergy = fairy.energy - minutes * _energyPerMinute;

    final hungerPressure = max(0, (updatedHunger - 40) / 60); // 0..1
    final energyPressure = max(0, (50 - updatedEnergy) / 50); // 0..1
    final moodDrift = (hungerPressure * 8 + energyPressure * 6) * minutes;

    final passiveExp = (minutes * _passiveExpPerMinute).floor();

    return _applyLeveling(
      fairy.copyWith(
        hunger: _clampStat(updatedHunger),
        energy: _clampStat(updatedEnergy),
        mood: _clampStat(fairy.mood - moodDrift),
        exp: fairy.exp + passiveExp,
      ),
    );
  }

  /// Applies a feed action and returns the updated fairy snapshot.
  Fairy feed(Fairy fairy) {
    final updated = fairy.copyWith(
      hunger: _clampStat(fairy.hunger - 20),
      mood: _clampStat(fairy.mood + 5),
      exp: fairy.exp + 5,
    );
    return _applyLeveling(updated);
  }

  /// Applies a play action and returns the updated fairy snapshot.
  Fairy play(Fairy fairy) {
    final updated = fairy.copyWith(
      energy: _clampStat(fairy.energy - 10),
      mood: _clampStat(fairy.mood + 15),
      exp: fairy.exp + 8,
    );
    return _applyLeveling(updated);
  }

  /// Applies a sleep action and returns the updated fairy snapshot.
  Fairy sleep(Fairy fairy) {
    final updated = fairy.copyWith(
      energy: _clampStat(fairy.energy + 30),
      mood: _clampStat(fairy.mood + 5),
    );
    return _applyLeveling(updated);
  }

  Fairy _applyLeveling(Fairy fairy) {
    var currentLevel = fairy.level;
    var currentExp = fairy.exp;

    while (currentExp >= currentLevel * 100) {
      currentExp -= currentLevel * 100;
      currentLevel += 1;
    }

    return fairy.copyWith(level: currentLevel, exp: currentExp);
  }
}
