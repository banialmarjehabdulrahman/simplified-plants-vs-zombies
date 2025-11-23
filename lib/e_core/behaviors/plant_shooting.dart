import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../a_game/pvz_game.dart';
import '../../b_components/plant.dart';
import '../../b_components/zombie.dart';
import '../../d_models/plant_type.dart';
import '../game_layout.dart';

class _ShootingProfile {
  _ShootingProfile({
    required this.fireInterval,
    required this.projectileSpeed,
    required this.damagePerShot,
    required this.color,
    this.isIce = false,
    this.doubleShot = false,
  });

  final double fireInterval;
  final double projectileSpeed;
  final int damagePerShot;
  final Color color;
  final bool isIce;
  final bool doubleShot;
}

/// System that handles shooting behavior for offensive plants.
class PlantShooting extends Component with HasGameRef<PvzGame> {
  PlantShooting();

  final Map<Plant, double> _timers = {};

  final Map<PlantType, _ShootingProfile> _profiles = {
    PlantType.peashooter: _ShootingProfile(
      fireInterval: 1.5,
      projectileSpeed: 400,
      damagePerShot: 35,
      color: Colors.greenAccent,
    ),
    PlantType.icePeashooter: _ShootingProfile(
      fireInterval: 1.8,
      projectileSpeed: 380,
      damagePerShot: 0, // pure slow
      color: Colors.lightBlueAccent,
      isIce: true,
    ),
    PlantType.fastPeashooter: _ShootingProfile(
      fireInterval: 0.9,
      projectileSpeed: 450,
      damagePerShot: 35,
      color: Colors.redAccent,
      doubleShot: true,
    ),
  };

  static const double _doubleShotDelay = 0.15;
  static const double _iceSlowFactor = 0.6; // 60% speed
  static const double _iceSlowDuration = 2.5; // seconds

  @override
  void update(double dt) {
    super.update(dt);

    _timers.removeWhere(
      (plant, _) => !plant.isMounted || !_profiles.containsKey(plant.type),
    );

    for (final plant in gameRef.children.whereType<Plant>()) {
      final profile = _profiles[plant.type];
      if (profile == null) continue;

      if (!_hasEnemyInLaneAhead(plant)) {
        continue;
      }

      _timers[plant] = (_timers[plant] ?? 0) + dt;

      if (_timers[plant]! >= profile.fireInterval) {
        _timers[plant] = 0;
        _fireVolley(plant, profile);
      }
    }
  }

  bool _hasEnemyInLaneAhead(Plant plant) {
    final laneIndex = plant.tile.gridY;
    final plantX = plant.position.x;

    for (final zombie in gameRef.children.whereType<Zombie>()) {
      if (zombie.laneIndex != laneIndex) continue;
      if (zombie.isDead) continue;
      if (zombie.position.x > plantX) {
        return true;
      }
    }

    return false;
  }

  void _fireVolley(Plant plant, _ShootingProfile profile) {
    if (profile.doubleShot) {
      _spawnProjectile(plant, profile);

      gameRef.add(
        TimerComponent(
          period: _doubleShotDelay,
          repeat: false,
          onTick: () {
            if (!plant.isMounted) return;
            _spawnProjectile(plant, profile);
          },
        ),
      );
    } else {
      _spawnProjectile(plant, profile);
    }
  }

  void _spawnProjectile(Plant plant, _ShootingProfile profile) {
    final laneIndex = plant.tile.gridY;

    // Spawn slightly in front of the plant.
    final spawnPos =
        plant.position +
        Vector2(GameLayout.tileSize * 0.3, -GameLayout.tileSize * 0.1);

    gameRef.projectilePool.spawnProjectile(
      laneIndex: laneIndex,
      damage: profile.isIce ? 0 : profile.damagePerShot,
      speed: profile.projectileSpeed,
      color: profile.color,
      slowMultiplier: profile.isIce ? _iceSlowFactor : null,
      slowDuration: profile.isIce ? _iceSlowDuration : null,
      startPosition: spawnPos,
    );

    // ignore: avoid_print
    print(
      'Plant ${plant.type} fired projectile at lane $laneIndex '
      'from (${spawnPos.x.toStringAsFixed(1)}, ${spawnPos.y.toStringAsFixed(1)}).',
    );
  }
}
