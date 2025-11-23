import 'package:flame/components.dart';

import '../../a_game/pvz_game.dart';
import '../../b_components/zombie.dart';
import '../../d_models/zombie_type.dart';

/// Object pool for [Zombie] components.
class ZombiePool {
  ZombiePool({required this.game});

  final PvzGame game;

  /// Inactive zombies ready to be reused.
  final List<Zombie> _available = [];

  int _createdCount = 0;

  int get availableCount => _available.length;
  int get inUseCount => _createdCount - _available.length;
  int get totalCreated => _createdCount;

  /// Spawn (or reuse) a zombie of [type] in [laneIndex] at [spawnPosition].
  Zombie spawnZombie({
    required ZombieType type,
    required int laneIndex,
    required Vector2 spawnPosition,
  }) {
    Zombie zombie;
    final sprite = game.zombieAssets.spriteFor(type);

    if (_available.isNotEmpty) {
      zombie = _available.removeLast();
      zombie.resetForSpawn(
        type: type,
        laneIndex: laneIndex,
        sprite: sprite,
        spawnPosition: spawnPosition,
      );

      // ignore: avoid_print
      print(
        '[ZombiePool] REUSE  | inUse=$inUseCount, '
        'available=$availableCount, totalCreated=$totalCreated',
      );
    } else {
      zombie = Zombie(type: type, laneIndex: laneIndex, sprite: sprite);
      zombie.position = spawnPosition.clone();
      _createdCount++;

      // ignore: avoid_print
      print(
        '[ZombiePool] CREATE | inUse=$inUseCount, '
        'available=$availableCount, totalCreated=$totalCreated',
      );
    }

    game.add(zombie);
    return zombie;
  }

  /// Return a zombie back to the pool.
  void release(Zombie zombie) {
    if (zombie.isMounted) {
      zombie.removeFromParent();
    }
    _available.add(zombie);

    // ignore: avoid_print
    print(
      '[ZombiePool] RELEASE | inUse=$inUseCount, '
      'available=$availableCount, totalCreated=$totalCreated',
    );
  }

  /// Manual debug print.
  void debugPrintState() {
    // ignore: avoid_print
    print(
      '[ZombiePool] STATE  | inUse=$inUseCount, '
      'available=$availableCount, totalCreated=$totalCreated',
    );
  }
}
