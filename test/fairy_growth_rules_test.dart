import 'package:flutter_test/flutter_test.dart';
import 'package:pokifairy/shared/model/fairy.dart';
import 'package:pokifairy/shared/model/growth_rules.dart';

void main() {
  final rules = const FairyGrowthRules();
  final baseFairy = Fairy(
    id: 'test',
    name: 'Lumi',
    species: FairySpecies.spirit,
    color: '#A0C3FF',
    level: 1,
    exp: 0,
    mood: 80,
    hunger: 20,
    energy: 80,
    createdAt: DateTime(2025, 1, 1),
    lastTick: DateTime(2025, 1, 1),
  );

  test('tick applies passive decay and keeps values clamped', () {
    final updated = rules.tick(
      fairy: baseFairy,
      delta: const Duration(minutes: 30),
    );

    expect(updated.hunger, inInclusiveRange(0, 100));
    expect(updated.energy, inInclusiveRange(0, 100));
    expect(updated.mood, inInclusiveRange(0, 100));
    expect(updated.exp >= baseFairy.exp, isTrue);
  });

  test('tick levels up when exp threshold is exceeded', () {
    final boosted = baseFairy.copyWith(exp: 90);
    final updated = rules.tick(
      fairy: boosted,
      delta: const Duration(minutes: 60),
    );

    expect(updated.level, greaterThanOrEqualTo(boosted.level));
    expect(updated.exp, lessThan(updated.level * 100));
  });
}
