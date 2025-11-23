import 'package:flutter/foundation.dart';

/// All different plant types we support.
enum PlantType { sunflower, peashooter, icePeashooter, fastPeashooter, wallnut }

/// Static info for one plant type: cost, icon, description, etc.
@immutable
class PlantDefinition {
  const PlantDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.cost,
    required this.iconPath,
  });

  final PlantType type;
  final String name;
  final String description;
  final int cost;
  final String iconPath;

  /// All plant types used by the game.
  static const List<PlantDefinition> all = [
    PlantDefinition(
      type: PlantType.sunflower,
      name: 'Sunflower',
      description: 'Generates sun over time.',
      cost: 50,
      iconPath: 'plants/sunflower.png',
    ),
    PlantDefinition(
      type: PlantType.peashooter,
      name: 'Peashooter',
      description: 'Shoots peas at normal speed.',
      cost: 100,
      iconPath: 'plants/peashooter.png',
    ),
    PlantDefinition(
      type: PlantType.icePeashooter,
      name: 'Ice Pea',
      description: 'Slows zombies with ice peas.',
      cost: 150,
      iconPath: 'plants/ice_peashooter_blue.png',
    ),
    PlantDefinition(
      type: PlantType.fastPeashooter,
      name: 'Fast Pea',
      description: 'Shoots peas very quickly.',
      cost: 175,
      iconPath: 'plants/fast_peashooter_red.png',
    ),
    PlantDefinition(
      type: PlantType.wallnut,
      name: 'Wall-nut',
      description: 'High health barrier.',
      cost: 75,
      iconPath: 'plants/wallnut.png',
    ),
  ];

  String get spritePath => iconPath;

  static PlantDefinition byType(PlantType type) {
    return all.firstWhere((d) => d.type == type);
  }
}
