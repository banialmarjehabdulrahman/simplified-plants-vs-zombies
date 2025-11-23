import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../a_game/pvz_game.dart';
import '../b_components/tile.dart';
import '../d_models/plant_type.dart';
import '../e_core/game_layout.dart';
import '../e_core/health/damageable.dart';
import '../e_core/health/health_component.dart';
import '../e_core/health/hit_invulnerability.dart';
import '../e_core/health/hit_flash.dart';

class Plant extends SpriteComponent
    with HasGameRef<PvzGame>
    implements Damageable {
  Plant({required this.type, required this.tile, required Sprite sprite})
    : super(
        sprite: sprite,
        size: Vector2.all(GameLayout.tileSize * 0.9),
        anchor: Anchor.center,
      ) {
    // Center the plant inside the tile.
    position =
        tile.position +
        Vector2(GameLayout.tileSize / 2, GameLayout.tileSize / 2);

    // Shared i-frame helper for this plant.
    hitInvulnerability = HitInvulnerability(duration: 0.2);

    // Shared hit-flash effect for this plant.
    hitFlash = HitFlashEffect(
      duration: 0.4, // visible for a bit
      baseColor: Colors.white,
      flashColorA: Colors.red,
      flashColorB: Colors.yellow,
      flashFrequency: 12.0,
    );

    // Initialize health AFTER 'this' exists.
    health = HealthComponent(
      owner: this,
      maxHealth: _defaultMaxHealthForType(type),
      onHealthChanged: _onHealthChanged,
      onDeath: _handleDeath,
      invulnerability: hitInvulnerability,
    );
  }

  final PlantType type;
  final Tile tile;

  /// Shared health logic for this plant.
  late final HealthComponent health;

  /// I-frame state for gameplay.
  late final HitInvulnerability hitInvulnerability;

  /// Visual hit flash effect.
  late final HitFlashEffect hitFlash;

  // ---- Idle animation state ----

  static const double _idlePeriod = 1.8; // seconds per full idle cycle
  static const double _idleAmplitude = 0.06; // how much it scales (6%)

  double _idleTime = 0.0;
  int _completedIdleCycles = 0;

  @override
  void onMount() {
    super.onMount();
    // Start with neutral scale and color.
    scale = Vector2.all(1.0);
    paint.color = Colors.white;
    paint.colorFilter = null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Tick any time-based health features (like i-frames).
    health.update(dt);

    // Tick hit flash effect.
    hitFlash.update(dt);

    // Idle "breathing" animation using scale.
    _idleTime += dt;

    final cyclesNow = (_idleTime / _idlePeriod).floor();
    if (cyclesNow > _completedIdleCycles) {
      _completedIdleCycles = cyclesNow;
      _onIdleCycleCompleted();
    }

    final t = (_idleTime % _idlePeriod) / _idlePeriod; // 0..1 within cycle
    final s = 1.0 + _idleAmplitude * math.sin(t * 2 * math.pi);
    scale.setValues(s, s);

    // Apply current flash tint using ColorFilter.
    if (hitFlash.isActive) {
      paint.colorFilter = ColorFilter.mode(
        hitFlash.currentColor,
        BlendMode.modulate,
      );
    } else {
      // No flash: remove tint.
      paint.colorFilter = null;
    }
  }

  // ---- Damageable implementation (delegating to HealthComponent) ----

  @override
  int get maxHealth => health.maxHealth;

  @override
  int get currentHealth => health.currentHealth;

  @override
  bool get isDead => health.isDead;

  @override
  void applyDamage(int amount) => health.applyDamage(amount);

  @override
  void heal(int amount) => health.heal(amount);

  @override
  void kill() => health.kill();

  // ---- Internal health handling ----

  void _onHealthChanged(int previous, int current) {
    // Trigger flash on damage (health decreasing).
    if (current < previous) {
      hitFlash.trigger();
    }

    // Debug.
    // ignore: avoid_print
    print(
      'Plant $type health changed at tile (${tile.gridX}, ${tile.gridY}): '
      '$previous -> $current',
    );
  }

  void _handleDeath() {
    tile.hasPlant = false;
    // ignore: avoid_print
    print('Plant $type died at tile (${tile.gridX}, ${tile.gridY})');
    removeFromParent();
  }

  void _onIdleCycleCompleted() {
    // Future shooting hook
    // ignore: avoid_print
    // print(
    //   'Plant $type finished IDLE cycle at tile (${tile.gridX}, ${tile.gridY})',
    // );
  }

  static int _defaultMaxHealthForType(PlantType type) {
    switch (type) {
      case PlantType.peashooter:
        return 100;
      case PlantType.sunflower:
        return 80;
      case PlantType.wallnut:
        return 300;
      case PlantType.icePeashooter:
        return 110;
      case PlantType.fastPeashooter:
        return 120;
    }
  }
}
