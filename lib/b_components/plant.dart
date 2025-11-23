import 'dart:math' as math;

import 'package:flame/components.dart';

import '../a_game/pvz_game.dart';
import '../b_components/tile.dart';
import '../d_models/plant_type.dart';
import '../e_core/game_layout.dart';

class Plant extends SpriteComponent with HasGameRef<PvzGame> {
  Plant({required this.type, required this.tile, required Sprite sprite})
    : super(
        sprite: sprite,
        size: Vector2.all(GameLayout.tileSize * 0.9),
        anchor: Anchor.center,
      ) {
    position =
        tile.position +
        Vector2(GameLayout.tileSize / 2, GameLayout.tileSize / 2);
  }

  final PlantType type;
  final Tile tile;

  // ---- Idle animation state ----
  static const double _idlePeriod = 1.8; // seconds per full idle cycle
  static const double _idleAmplitude = 0.06; // how much it scales (6%)

  double _idleTime = 0.0;
  int _completedIdleCycles = 0;

  @override
  void onMount() {
    super.onMount();
    // Start with neutral scale.
    scale = Vector2.all(1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Advance idle time
    _idleTime += dt;

    // 2. Check if we completed another idle cycle
    final cyclesNow = (_idleTime / _idlePeriod).floor();
    if (cyclesNow > _completedIdleCycles) {
      _completedIdleCycles = cyclesNow;
      _onIdleCycleCompleted(); // <-- SHOOT HOOK (for now: print)
    }

    // 3. Apply idle "breathing" scale (sine wave)
    final t = (_idleTime % _idlePeriod) / _idlePeriod; // 0..1 within cycle
    final s = 1.0 + _idleAmplitude * math.sin(t * 2 * math.pi);
    scale.setValues(s, s);
  }

  void _onIdleCycleCompleted() {
    // This is where we will shoot later.
    // ignore: avoid_print
    print(
      'Plant $type finished IDLE cycle at tile (${tile.gridX}, ${tile.gridY})',
    );
  }

  // Keep this for later if you still want a manual "shoot" trigger:
  void playShootAnimation() {
    // For now we can just log, or you can add a different animation here later.
    // ignore: avoid_print
    print(
      'Plant $type manually triggered shoot at tile (${tile.gridX}, ${tile.gridY})',
    );
  }
}
