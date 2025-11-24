// lib/b_components/plant.dart
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/game/config/game_layout.dart';
import '../../core/health/damageable.dart';
import '../../core/health/health_component.dart';
import '../../core/health/hit_flash.dart';
import '../../core/health/hit_invulnerability.dart';
import '../../game/pvz_game.dart';
import '../models/plant_type.dart';
import 'tile.dart';

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

  // ---- Idle animation state (scale breathing) ----

  static const double _idlePeriod = 1.8; // seconds per full idle cycle
  static const double _idleAmplitude = 0.06; // how much it scales (6%)

  double _idleTime = 0.0;
  int _completedIdleCycles = 0;

  // ---- Walnut frame animation ----

  /// Frames for the walnut-only animation.
  List<Sprite>? _walnutFrames;

  /// How long each walnut frame is shown.
  static const double _walnutFrameDuration = 0.15;

  double _walnutAnimTime = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Start with neutral scale and color.
    scale = Vector2.all(1.0);
    paint.color = Colors.white;
    paint.colorFilter = null;

    // Load animation frames only for the walnut plant type.
    if (type == PlantType.walnut) {
      const basePath = 'plants/walnut_keyframes';

      _walnutFrames = await Future.wait([
        gameRef.loadSprite('$basePath/walnut_frame_1.png'),
        gameRef.loadSprite('$basePath/walnut_frame_2.png'),
        gameRef.loadSprite('$basePath/walnut_frame_3.png'),
        gameRef.loadSprite('$basePath/walnut_frame_4.png'),
      ]);

      if (_walnutFrames!.isNotEmpty) {
        sprite = _walnutFrames!.first;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Tick any time-based health features (like i-frames).
    health.update(dt);

    // Tick hit flash effect.
    hitFlash.update(dt);

    // --- Visual idle / animation ---

    if (type == PlantType.walnut && _walnutFrames != null) {
      // Walnut uses its frame animation, not the scale breathing.
      _walnutAnimTime += dt;

      final frameCount = _walnutFrames!.length;
      if (frameCount > 0) {
        final frameIndex =
            (_walnutAnimTime / _walnutFrameDuration).floor() % frameCount;
        sprite = _walnutFrames![frameIndex];
      }
    } else {
      // Other plants: idle "breathing" animation using scale.
      _idleTime += dt;

      final cyclesNow = (_idleTime / _idlePeriod).floor();
      if (cyclesNow > _completedIdleCycles) {
        _completedIdleCycles = cyclesNow;
        _onIdleCycleCompleted();
      }

      final t = (_idleTime % _idlePeriod) / _idlePeriod; // 0..1 within cycle
      final s = 1.0 + _idleAmplitude * math.sin(t * 2 * math.pi);
      scale.setValues(s, s);
    }

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

  @override
  void render(Canvas canvas) {
    // --- Fake "drop shadow" under the plant (simple oval) ---
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // Local coordinates: (0,0) is top-left of the component.
    final shadowCenter = Offset(size.x / 2, size.y * 0.85);
    final shadowRect = Rect.fromCenter(
      center: shadowCenter,
      width: size.x * 0.7,
      height: size.y * 0.22,
    );

    canvas.drawOval(shadowRect, shadowPaint);

    // Then draw the plant sprite as usual.
    super.render(canvas);
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
    // Future shooting hook if needed later.
  }

  static int _defaultMaxHealthForType(PlantType type) {
    switch (type) {
      case PlantType.peashooter:
        return 100;
      case PlantType.sunflower:
        return 80;
      case PlantType.walnut:
        return 300;
      case PlantType.icePeashooter:
        return 110;
      case PlantType.fastPeashooter:
        return 120;
    }
  }
}
