/// Species categories available for fairy companions.
enum FairySpecies {
  /// Ethereal spirit-type fairy.
  spirit,

  /// Nature-bound elf archetype.
  elf,

  /// Human-like fairy companion.
  humanlike,
}

/// Provides helpers for serializing [FairySpecies] values.
extension FairySpeciesX on FairySpecies {
  /// String identifier stored in preferences.
  String get key => switch (this) {
    FairySpecies.spirit => 'spirit',
    FairySpecies.elf => 'elf',
    FairySpecies.humanlike => 'humanlike',
  };

  /// Localized lookup key for displaying the species label.
  String get localizationKey => switch (this) {
    FairySpecies.spirit => 'speciesSpirit',
    FairySpecies.elf => 'speciesElf',
    FairySpecies.humanlike => 'speciesHumanlike',
  };
}

/// Parses a [FairySpecies] from the stored [value].
FairySpecies parseFairySpecies(String value) {
  return FairySpecies.values.firstWhere(
    (species) => species.key == value,
    orElse: () => FairySpecies.spirit,
  );
}

/// Immutable model describing a pocket fairy companion.
class Fairy {
  /// Creates a [Fairy] with the provided attributes.
  const Fairy({
    required this.id,
    required this.name,
    required this.species,
    required this.color,
    required this.imageIndex,
    required this.level,
    required this.exp,
    required this.mood,
    required this.hunger,
    required this.energy,
    required this.createdAt,
    required this.lastTick,
  });

  /// Unique identifier for the fairy profile.
  final String id;

  /// Display name chosen by the user.
  final String name;

  /// Species archetype for presentation purposes.
  final FairySpecies species;

  /// Preferred color accent encoded as a hex string (e.g. #AABBCC).
  final String color;

  /// Index of the selected fairy image (0-7).
  final int imageIndex;

  /// Current level representing long-term growth.
  final int level;

  /// Experience points accumulated toward the next level.
  final int exp;

  /// Current mood value clamped between 0 and 100.
  final int mood;

  /// Current hunger value clamped between 0 and 100.
  final int hunger;

  /// Current energy value clamped between 0 and 100.
  final int energy;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Timestamp of the last lifecycle update.
  final DateTime lastTick;

  /// Creates a modified copy of this [Fairy].
  Fairy copyWith({
    String? id,
    String? name,
    FairySpecies? species,
    String? color,
    int? imageIndex,
    int? level,
    int? exp,
    int? mood,
    int? hunger,
    int? energy,
    DateTime? createdAt,
    DateTime? lastTick,
  }) {
    return Fairy(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      color: color ?? this.color,
      imageIndex: imageIndex ?? this.imageIndex,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      mood: mood ?? this.mood,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      createdAt: createdAt ?? this.createdAt,
      lastTick: lastTick ?? this.lastTick,
    );
  }

  /// Serializes the fairy into a JSON-compatible map.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'species': species.key,
      'color': color,
      'imageIndex': imageIndex,
      'level': level,
      'exp': exp,
      'mood': mood,
      'hunger': hunger,
      'energy': energy,
      'createdAt': createdAt.toIso8601String(),
      'lastTick': lastTick.toIso8601String(),
    };
  }

  /// Restores a [Fairy] from persisted JSON data.
  factory Fairy.fromJson(Map<String, Object?> json) {
    return Fairy(
      id: json['id'] as String,
      name: json['name'] as String,
      species: parseFairySpecies(json['species'] as String),
      color: json['color'] as String,
      imageIndex: json['imageIndex'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      exp: json['exp'] as int? ?? 0,
      mood: json['mood'] as int? ?? 70,
      hunger: json['hunger'] as int? ?? 30,
      energy: json['energy'] as int? ?? 80,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastTick: DateTime.parse(json['lastTick'] as String),
    );
  }
}
