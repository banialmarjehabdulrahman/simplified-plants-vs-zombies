// lib/b_components/projectile.dart
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/effects/projectile_hit_particle.dart';
import '../../game/pvz_game.dart';
import 'zombie.dart';

/// Simple circular projectile fired by plants.
///
/// Handles:
/// - Moving to the right
/// - Checking collisions with zombies in the same lane
/// - Applying damage and optional slow effect
/// - Returning itself to the projectile pool when done
class Projectile extends PositionComponent with HasGameRef<PvzGame> {
  Projectile.pooled({
    required int laneIndex,
    required int damage,
    required double speed,
    required Color color,
    double? slowMultiplier,
    double? slowDuration,
    required Vector2 startPosition,
  }) : _laneIndex = laneIndex,
       _damage = damage,
       _speed = speed,
       _color = color,
       _slowMultiplier = slowMultiplier,
       _slowDuration = slowDuration,
       super(
         position: startPosition.clone(),
         anchor: Anchor.center,
         size: Vector2.all(16), // circle diameter
         priority: 500, // above tiles, below UI
       );

  // ----- mutable fields for pooling -----

  int _laneIndex;
  int _damage;
  double _speed;
  Color _color;
  double? _slowMultiplier;
  double? _slowDuration;

  int get laneIndex => _laneIndex;
  int get damage => _damage;
  double get speed => _speed;
  Color get color => _color;
  double? get slowMultiplier => _slowMultiplier;
  double? get slowDuration => _slowDuration;

  /// Reconfigure this projectile for a new shot.
  void reset({
    required int laneIndex,
    required int damage,
    required double speed,
    required Color color,
    double? slowMultiplier,
    double? slowDuration,
    required Vector2 startPosition,
  }) {
    _laneIndex = laneIndex;
    _damage = damage;
    _speed = speed;
    _color = color;
    _slowMultiplier = slowMultiplier;
    _slowDuration = slowDuration;

    position.setFrom(startPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move to the right.
    position.x += _speed * dt;

    // Remove if far off the right side of the visible world.
    final visibleRect = gameRef.camera.visibleWorldRect;
    if (position.x > visibleRect.right + 200) {
      _despawn();
      return;
    }

    // Check collision with zombies in the same lane.
    for (final zombie in gameRef.children.whereType<Zombie>()) {
      if (zombie.laneIndex != _laneIndex) continue;
      if (zombie.isDead) continue;

      if (_overlapsZombie(zombie)) {
        _onHitZombie(zombie);
        _despawn();
        break;
      }
    }
  }

  bool _overlapsZombie(Zombie zombie) {
    final projRect = ui.Rect.fromLTWH(
      position.x - size.x / 2,
      position.y - size.y / 2,
      size.x,
      size.y,
    );

    final zombieRect = ui.Rect.fromLTWH(
      zombie.position.x - zombie.size.x / 2,
      zombie.position.y - zombie.size.y / 2,
      zombie.size.x,
      zombie.size.y,
    );

    return projRect.overlaps(zombieRect);
  }

  void _onHitZombie(Zombie zombie) {
    // Particle effect at the hit position (using projectile color).
    gameRef.add(
      ProjectileHitParticle(worldPosition: position.clone(), color: _color),
    );

    if (_damage > 0) {
      zombie.applyDamage(_damage);
    }

    if (_slowMultiplier != null && _slowDuration != null) {
      zombie.applySlow(_slowMultiplier!, _slowDuration!);
    }
  }

  void _despawn() {
    // Return to projectile pool instead of directly removing.
    gameRef.projectilePool.release(this);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = _color;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
