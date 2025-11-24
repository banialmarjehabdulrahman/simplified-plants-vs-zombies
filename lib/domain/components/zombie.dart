// lib/b_components/zombie.dart
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/audio/audio_manager.dart';
import '../../core/game/config/game_layout.dart';
import '../../core/health/damageable.dart';
import '../../core/health/health_component.dart';
import '../../core/health/hit_flash.dart';
import '../../core/health/hit_invulnerability.dart';
import '../../core/patterns/state/game_state.dart';
import '../../game/pvz_game.dart';
import '../models/zombie_type.dart';

/// ---------------------------------------------------------------------------
/// Strategy pattern: movement behaviors for zombies
/// ---------------------------------------------------------------------------

/// Strategy interface for zombie movement.
///
/// Different movement styles (straight walk, fast walk, zig-zag, etc.)
/// implement this and can be plugged into [Zombie].
abstract class ZombieMovementStrategy {
  void update(Zombie zombie, double dt);
}

/// Default movement: walk left at zombie.speed, with bobbing and slight tilt.
class StraightWalkMovement implements ZombieMovementStrategy {
  StraightWalkMovement({
    this.bobPeriod = 0.8,
    this.bobAmplitude = 4.0,
    this.tiltAngle = 0.04,
  });

  /// Time for one bobbing cycle.
  final double bobPeriod;

  /// How far up/down the zombie bobs.
  final double bobAmplitude;

  /// How much the zombie tilts while walking.
  final double tiltAngle;

  double _walkTime = 0.0;
  double? _baseY;

  @override
  void update(Zombie zombie, double dt) {
    // Lazily capture the "base" Y on first update.
    _baseY ??= zombie.position.y;

    // Movement: speed from definition * any active slow effect.
    final speed = zombie.def.speed * zombie.speedMultiplier;
    zombie.position.x -= speed * dt;

    // Bobbing + tilt animation.
    _walkTime += dt;
    final t = (_walkTime % bobPeriod) / bobPeriod;
    final bobOffset = bobAmplitude * math.sin(t * 2 * math.pi);
    zombie.position.y = _baseY! + bobOffset;

    zombie.angle = tiltAngle * math.sin(t * 2 * math.pi);
  }
}

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

  // Strategy used to move this zombie each frame.
  late ZombieMovementStrategy _movementStrategy;

  // ---- Slow / status effect state ----
  double _speedMultiplier = 1.0;
  double _slowTimer = 0.0;

  // To avoid re-initialising late finals when reused from pool.
  bool _initialized = false;

  /// Expose speed multiplier so movement strategies can use it.
  double get speedMultiplier => _speedMultiplier;

  @override
  void onMount() {
    super.onMount();

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

    // Default movement strategy (can be swapped per type if desired).
    _movementStrategy = StraightWalkMovement();

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

    // Reset movement strategy for a fresh walk.
    _movementStrategy = StraightWalkMovement();

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

    // Apply movement via the Strategy.
    _movementStrategy.update(this, dt);

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
    // SAFETY GUARD:
    // When zombies are being reset/spawned from the pool, HealthComponent.reset
    // can trigger this callback before the zombie is attached to the game tree.
    // In that case, using gameRef (from HasGameRef) throws an assertion.
    if (!isMounted || parent == null) {
      return;
    }

    if (current < previous) {
      // Took damage: trigger visual flash + hurt SFX (while playing).
      hitFlash.trigger();

      if (!isDead && gameRef.gameStateManager.status == GameStatus.playing) {
        AudioManager.instance.playZombieHurt();
      }
    }

    // ignore: avoid_print
    print('Zombie ${def.displayName} HP: $previous -> $current');
  }

  void _handleDeath() {
    // Only count kills & play SFX while the game is still being played.
    if (gameRef.gameStateManager.status == GameStatus.playing) {
      gameRef.killCounter.registerKill();
      AudioManager.instance.playZombieDie();
    }

    // Then recycle this zombie into the pool as before.
    gameRef.zombiePool.release(this);
  }

  void _onReachedHouse() {
    // Play "reached house" SFX (only if game is still active).
    if (gameRef.gameStateManager.status == GameStatus.playing) {
      AudioManager.instance.playZombieReachHouse();
    }

    // First, tell the game that the player loses one life.
    gameRef.playerHealth.loseLife();

    // Debug log (optional).
    // ignore: avoid_print
    print('Zombie ${def.displayName} reached the house (pooled).');

    // Then recycle this zombie back into the pool.
    gameRef.zombiePool.release(this);
  }
}
