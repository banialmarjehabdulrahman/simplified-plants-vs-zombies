import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../a_game/pvz_game.dart';
import '../d_models/zombie_type.dart';
import '../e_core/game_layout.dart';
import '../e_core/health/damageable.dart';
import '../e_core/health/health_component.dart';
import '../e_core/health/hit_invulnerability.dart';
import '../e_core/health/hit_flash.dart';

/// Visual + gameplay representation of a zombie walking on a lane.
///
/// All zombie types use this same class; stats come from [ZombieDefinition].
class Zombie extends SpriteComponent
    with HasGameRef<PvzGame>
    implements Damageable {
  Zombie({
    required ZombieType type,
    required int laneIndex,
    required Sprite sprite,
  }) : super(
         sprite: sprite,
         size: Vector2.all(GameLayout.tileSize * 0.9),
         anchor: Anchor.center,
       ) {
    this.type = type;
    this.laneIndex = laneIndex;
    def = ZombieCatalog.ofType(type);
  }

  /// Mutable so the pool can reuse the same instance for different types/lanes.
  late ZombieType type;
  late ZombieDefinition def;
  late int laneIndex;

  late final HealthComponent health;
  late final HitInvulnerability hitInvulnerability;
  late final HitFlashEffect hitFlash;

  static const double _bobPeriod = 0.8;
  static const double _bobAmplitude = 4.0;
  static const double _tiltAngle = 0.04;

  double _walkTime = 0.0;
  double _baseY = 0.0;

  // ---- Slow / status effect state ----
  double _speedMultiplier = 1.0;
  double _slowTimer = 0.0;

  // To avoid re-initialising late finals when reused from pool.
  bool _initialized = false;

  @override
  void onMount() {
    super.onMount();

    _baseY = position.y;

    if (!_initialized) {
      // One-time setup for this instance.
      hitInvulnerability = HitInvulnerability(duration: 0.25);

      hitFlash = HitFlashEffect(
        duration: 0.4,
        baseColor: Colors.white,
        flashColorA: Colors.red,
        flashColorB: Colors.yellow,
        flashFrequency: 12.0,
      );

      health = HealthComponent(
        owner: this,
        maxHealth: def.maxHealth,
        onHealthChanged: _onHealthChanged,
        onDeath: _handleDeath,
        invulnerability: hitInvulnerability,
      );

      _initialized = true;
    }

    // Reset visual state each time we’re mounted.
    scale = Vector2.all(1.0);
    paint.color = Colors.white;
    paint.colorFilter = null;

    // ignore: avoid_print
    print(
      'Zombie mounted: ${def.displayName} in lane $laneIndex '
      'with ${def.maxHealth} HP and speed ${def.speed}',
    );
  }

  /// Reconfigure this zombie when reusing from the pool.
  void resetForSpawn({
    required ZombieType type,
    required int laneIndex,
    required Sprite sprite,
    required Vector2 spawnPosition,
  }) {
    this.type = type;
    this.laneIndex = laneIndex;
    def = ZombieCatalog.ofType(type);
    this.sprite = sprite;

    position.setFrom(spawnPosition);
    _baseY = spawnPosition.y;
    _walkTime = 0.0;

    _speedMultiplier = 1.0;
    _slowTimer = 0.0;
    angle = 0.0;
    scale.setValues(1.0, 1.0);

    paint.color = Colors.white;
    paint.colorFilter = null;

    // Reset health & invulnerability / flash state if already initialized.
    if (_initialized) {
      hitFlash.reset();
      hitInvulnerability.reset();
      health.reset(maxHealth: def.maxHealth);
    }

    // ignore: avoid_print
    print(
      'Zombie RESET: ${def.displayName} lane=$laneIndex '
      'hp=${def.maxHealth} speed=${def.speed}',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    health.update(dt);
    hitFlash.update(dt);

    // Update slow timer & speed multiplier.
    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) {
        _slowTimer = 0;
        _speedMultiplier = 1.0;
      }
    }

    // Movement (affected by slow).
    position.x -= def.speed * _speedMultiplier * dt;

    _walkTime += dt;
    final t = (_walkTime % _bobPeriod) / _bobPeriod;
    final bobOffset = _bobAmplitude * math.sin(t * 2 * math.pi);
    position.y = _baseY + bobOffset;

    angle = _tiltAngle * math.sin(t * 2 * math.pi);

    // Apply flash tint using ColorFilter.
    if (hitFlash.isActive) {
      paint.colorFilter = ColorFilter.mode(
        hitFlash.currentColor,
        BlendMode.modulate,
      );
    } else {
      paint.colorFilter = null;
    }

    if (position.x < -size.x) {
      _onReachedHouse();
    }
  }

  // ---- Damageable implementation ----

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

  // ---- Slow effect API ----

  /// Apply a slow effect: [factor] = fraction of base speed (0.6 = 60% speed),
  /// [duration] = seconds the slow lasts.
  void applySlow(double factor, double duration) {
    if (factor < 0) factor = 0;
    if (factor > 1) factor = 1;

    _speedMultiplier = factor;
    _slowTimer = duration;

    // ignore: avoid_print
    print(
      'Zombie ${def.displayName} slowed to '
      '${(_speedMultiplier * 100).toStringAsFixed(0)}% '
      'for ${_slowTimer.toStringAsFixed(2)}s',
    );
  }

  // ---- Health callbacks ----

  void _onHealthChanged(int previous, int current) {
    if (current < previous) {
      hitFlash.trigger();
    }

    // ignore: avoid_print
    print('Zombie ${def.displayName} HP: $previous -> $current');
  }

  void _handleDeath() {
    // ignore: avoid_print
    print('Zombie ${def.displayName} died (pooled).');
    gameRef.zombiePool.release(this);
  }

  void _onReachedHouse() {
    // ignore: avoid_print
    print('Zombie ${def.displayName} reached the house (pooled).');
    gameRef.zombiePool.release(this);
  }
}
