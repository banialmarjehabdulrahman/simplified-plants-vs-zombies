import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/audio/audio_manager.dart';
import '../../core/game/config/game_layout.dart';
import '../../game/pvz_game.dart';
import '../components/plant.dart';
import '../components/zombie.dart';
import '../models/plant_type.dart';

class _ShootingProfile {
  _ShootingProfile({
    required this.fireInterval,
    required this.projectileSpeed,
    required this.damagePerShot,
    required this.color,
    this.isIce = false,
  });

  final double fireInterval;
  final double projectileSpeed;
  final int damagePerShot;
  final Color color;
  final bool isIce;
}

class PlantShooting extends Component with HasGameRef<PvzGame> {
  PlantShooting();

  /// How much slowing effect an ice projectile applies.
  static const double _iceSlowFactor = 0.5;

  /// How long the slow lasts.
  static const double _iceSlowDuration = 2.0;

  /// Per-plant firing timers.
  final Map<Plant, double> _timers = {};

  /// Shooting behavior per plant type.
  final Map<PlantType, _ShootingProfile> _profiles = {
    PlantType.fastPeashooter: _ShootingProfile(
      fireInterval: 1.1,
      projectileSpeed: 400,
      damagePerShot: 25,
      color: const Color.fromARGB(255, 255, 0, 0),
    ),
    PlantType.peashooter: _ShootingProfile(
      fireInterval: 0.8,
      projectileSpeed: 380,
      damagePerShot: 20,
      color: const Color.fromARGB(255, 255, 208, 0),
    ),
    PlantType.icePeashooter: _ShootingProfile(
      fireInterval: 1.2,
      projectileSpeed: 450,
      damagePerShot: 15,
      color: Colors.cyan,
      isIce: true,
    ),
  };

  @override
  void update(double dt) {
    super.update(dt);

    // Loop over all plants currently in the game.
    final plants = gameRef.children.whereType<Plant>();

    for (final plant in plants) {
      final profile = _profiles[plant.type];
      if (profile == null) continue;

      // Update this plant's timer.
      final currentTimer = _timers[plant] ?? 0;
      final newTimer = currentTimer + dt;

      if (newTimer >= profile.fireInterval) {
        // Time to shoot, but only if there's at least one zombie ahead
        // in the same lane.
        final laneIndex = plant.tile.gridY;
        final hasTargetAhead = gameRef.children.whereType<Zombie>().any(
          (z) => z.laneIndex == laneIndex && z.position.x > plant.position.x,
        );

        if (hasTargetAhead) {
          _spawnProjectile(plant, profile);
          _timers[plant] = 0;
        } else {
          _timers[plant] = profile.fireInterval; // clamp
        }
      } else {
        _timers[plant] = newTimer;
      }
    }

    // Clean up timers for plants that were removed.
    _timers.removeWhere((plant, _) => !plant.isMounted || plant.isDead);
  }

  void _spawnProjectile(Plant plant, _ShootingProfile profile) {
    final laneIndex = plant.tile.gridY;

    // Spawn slightly in front of the plant.
    final spawnPos =
        plant.position +
        Vector2(GameLayout.tileSize * 0.3, -GameLayout.tileSize * 0.1);

    // Helper that fires a single projectile + SFX + debug.
    void fireOne() {
      // If plant was removed or died in the meantime, skip.
      if (!plant.isMounted || plant.isDead) {
        return;
      }

      gameRef.projectilePool.spawnProjectile(
        laneIndex: laneIndex,
        damage: profile.isIce ? 0 : profile.damagePerShot,
        speed: profile.projectileSpeed,
        color: profile.color,
        slowMultiplier: profile.isIce ? _iceSlowFactor : null,
        slowDuration: profile.isIce ? _iceSlowDuration : null,
        startPosition: spawnPos,
      );

      // SFX: peashooter shot.
      AudioManager.instance.playPlantShootPeashooter();

      // ignore: avoid_print
      print(
        'Plant ${plant.type} fired projectile at lane $laneIndex '
        'from (${spawnPos.x.toStringAsFixed(1)}, '
        '${spawnPos.y.toStringAsFixed(1)}).',
      );
    }

    if (plant.type == PlantType.fastPeashooter) {
      // Fire one shot immediately...
      fireOne();

      // ...and a second shot shortly after (small delay so it's visible).
      async.Timer(const Duration(milliseconds: 150), () {
        fireOne();
      });
    } else {
      fireOne();
    }
  }
}
