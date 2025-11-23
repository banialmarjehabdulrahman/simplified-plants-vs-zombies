/// Different zombie archetypes in the game.
///
/// All zombies share the same underlying Zombie class,
/// but their stats (health, speed, damage, etc.) come from [ZombieDefinition].
enum ZombieType { brute, crawler, ghoul, runner, stalker }

/// Immutable stats for a given zombie type.
///
/// This is pure data: it has no logic, so it’s easy to tweak/balance.
class ZombieDefinition {
  const ZombieDefinition({
    required this.type,
    required this.displayName,
    required this.maxHealth,
    required this.speed,
    required this.damage,
    required this.spriteKey,
    this.description = '',
  });

  /// Which zombie type this definition is for.
  final ZombieType type;

  /// Friendly name for UI / debugging.
  final String displayName;

  /// Maximum health points.
  final int maxHealth;

  /// Movement speed in units per second (we’ll interpret this
  /// in the Zombie component later).
  final double speed;

  /// How much damage this zombie does per attack tick
  /// (when we add plant-chomping logic).
  final int damage;

  /// Key / path used to look up the sprite in the asset loader.
  ///
  /// Example: "brute_zombie" mapped to "assets/images/zombies/brute_zombie.png"
  /// in your images loader.
  final String spriteKey;

  /// Optional short description (can be used later in a bestiary or debug).
  final String description;
}

/// Central place where all zombie stats live.
/// Easy to tweak numbers for balancing.
class ZombieCatalog {
  static const ZombieDefinition brute = ZombieDefinition(
    type: ZombieType.brute,
    displayName: 'Brute Zombie',
    maxHealth: 300,
    speed: 25, // slow but tanky
    damage: 20,
    spriteKey: 'brute_zombie',
    description: 'Slow, heavily armored zombie that soaks a lot of damage.',
  );

  static const ZombieDefinition crawler = ZombieDefinition(
    type: ZombieType.crawler,
    displayName: 'Crawler Zombie',
    maxHealth: 80,
    speed: 18, // very slow but small
    damage: 10,
    spriteKey: 'crawler_zombie',
    description: 'Low health, very slow, but can be dangerous in groups.',
  );

  static const ZombieDefinition ghoul = ZombieDefinition(
    type: ZombieType.ghoul,
    displayName: 'Ghoul Zombie',
    maxHealth: 140,
    speed: 35,
    damage: 15,
    spriteKey: 'ghoul_zombie',
    description: 'Balanced zombie with average speed and health.',
  );

  static const ZombieDefinition runner = ZombieDefinition(
    type: ZombieType.runner,
    displayName: 'Runner Zombie',
    maxHealth: 90,
    speed: 60, // very fast
    damage: 12,
    spriteKey: 'runner_zombie',
    description: 'Fast zombie that rushes plants but is easier to kill.',
  );

  static const ZombieDefinition stalker = ZombieDefinition(
    type: ZombieType.stalker,
    displayName: 'Stalker Zombie',
    maxHealth: 180,
    speed: 40,
    damage: 18,
    spriteKey: 'stalker_zombie',
    description: 'Tough and moderately fast, a mid-tier threat.',
  );

  /// List of all definitions (useful for random selection, etc.).
  static const List<ZombieDefinition> all = [
    brute,
    crawler,
    ghoul,
    runner,
    stalker,
  ];

  /// Quick lookup by [ZombieType].
  static ZombieDefinition ofType(ZombieType type) {
    switch (type) {
      case ZombieType.brute:
        return brute;
      case ZombieType.crawler:
        return crawler;
      case ZombieType.ghoul:
        return ghoul;
      case ZombieType.runner:
        return runner;
      case ZombieType.stalker:
        return stalker;
    }
  }
}
