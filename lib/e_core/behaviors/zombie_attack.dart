import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../../a_game/pvz_game.dart';
import '../../b_components/plant.dart';
import '../../b_components/zombie.dart';
import '../effects/zombie_explosion_effect.dart';

/// System that makes zombies damage plants when they collide,
/// and then explode & die.
///
/// All logic is here; Plant stays clean.
class ZombieAttack extends Component with HasGameRef<PvzGame> {
  ZombieAttack();

  @override
  void update(double dt) {
    super.update(dt);

    final zombies = gameRef.children.whereType<Zombie>().toList();
    final plants = gameRef.children.whereType<Plant>().toList();

    for (final zombie in zombies) {
      if (zombie.isDead) continue;

      // Find any plant this zombie is overlapping with in the same lane.
      final targetPlant = _findCollidingPlant(zombie, plants);
      if (targetPlant == null) {
        continue;
      }

      // On first contact: damage plant, spawn explosion, kill zombie.
      _explodeZombieOnPlant(zombie, targetPlant);
    }
  }

  Plant? _findCollidingPlant(Zombie zombie, List<Plant> plants) {
    for (final plant in plants) {
      // Same lane? (Zombie uses laneIndex, plant uses tile.gridY).
      if (plant.tile.gridY != zombie.laneIndex) continue;

      if (_overlaps(zombie, plant)) {
        return plant;
      }
    }
    return null;
  }

  bool _overlaps(Zombie zombie, Plant plant) {
    final zombieRect = ui.Rect.fromLTWH(
      zombie.position.x - zombie.size.x / 2,
      zombie.position.y - zombie.size.y / 2,
      zombie.size.x,
      zombie.size.y,
    );

    final plantRect = ui.Rect.fromLTWH(
      plant.position.x - plant.size.x / 2,
      plant.position.y - plant.size.y / 2,
      plant.size.x,
      plant.size.y,
    );

    return zombieRect.overlaps(plantRect);
  }

  void _explodeZombieOnPlant(Zombie zombie, Plant plant) {
    // Damage the plant based on zombie's defined damage.
    final damage = zombie.def.damage;
    plant.applyDamage(damage);

    // Debug log.
    // ignore: avoid_print
    print(
      'Zombie ${zombie.def.displayName} collided with plant ${plant.type} '
      'at (${plant.tile.gridX}, ${plant.tile.gridY}) for $damage damage, then exploded.',
    );

    // Spawn explosion effect at zombie position.
    final explosion = ZombieExplosionEffect(worldPosition: zombie.position);
    gameRef.add(explosion);

    // Kill the zombie (goes through HealthComponent, i-frames etc).
    zombie.kill();
  }
}
