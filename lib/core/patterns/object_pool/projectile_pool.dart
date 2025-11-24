import 'package:flame/components.dart'; // Vector2
import 'package:flutter/material.dart';

import '../../../domain/components/projectile.dart';
import '../../../game/pvz_game.dart'; // Color

/// Simple object pool for [Projectile] components.
class ProjectilePool {
  ProjectilePool({required this.game});

  final PvzGame game;

  /// Inactive projectiles ready to be reused.
  final List<Projectile> _available = [];

  /// How many projectiles have ever been created.
  int _createdCount = 0;

  int get availableCount => _available.length;
  int get inUseCount => _createdCount - _available.length;
  int get totalCreated => _createdCount;

  /// Acquire a projectile, configuring it for this shot.
  Projectile spawnProjectile({
    required int laneIndex,
    required int damage,
    required double speed,
    required Color color,
    double? slowMultiplier,
    double? slowDuration,
    required Vector2 startPosition,
  }) {
    Projectile proj;

    if (_available.isNotEmpty) {
      // Reuse an existing instance.
      proj = _available.removeLast();
      proj.reset(
        laneIndex: laneIndex,
        damage: damage,
        speed: speed,
        color: color,
        slowMultiplier: slowMultiplier,
        slowDuration: slowDuration,
        startPosition: startPosition,
      );

      // ignore: avoid_print
      print(
        '[ProjectilePool] REUSE  | inUse=$inUseCount, '
        'available=$availableCount, totalCreated=$totalCreated',
      );
    } else {
      // Create a brand new projectile.
      proj = Projectile.pooled(
        laneIndex: laneIndex,
        damage: damage,
        speed: speed,
        color: color,
        slowMultiplier: slowMultiplier,
        slowDuration: slowDuration,
        startPosition: startPosition,
      );
      _createdCount++;

      // ignore: avoid_print
      print(
        '[ProjectilePool] CREATE | inUse=$inUseCount, '
        'available=$availableCount, totalCreated=$totalCreated',
      );
    }

    game.add(proj);
    return proj;
  }

  /// Return a projectile back to the pool.
  void release(Projectile projectile) {
    if (projectile.isMounted) {
      projectile.removeFromParent();
    }
    _available.add(projectile);

    // ignore: avoid_print
    print(
      '[ProjectilePool] RELEASE | inUse=$inUseCount, '
      'available=$availableCount, totalCreated=$totalCreated',
    );
  }

  /// Manual debug helper if you want to log from outside.
  void debugPrintState() {
    // ignore: avoid_print
    print(
      '[ProjectilePool] STATE  | inUse=$inUseCount, '
      'available=$availableCount, totalCreated=$totalCreated',
    );
  }
}
