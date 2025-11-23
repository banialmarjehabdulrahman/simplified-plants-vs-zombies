import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../b_components/tile.dart';
import '../b_components/plant.dart';
import '../b_components/zombie.dart';
import '../d_models/plant_type.dart';
import '../e_core/game_layout.dart';
import '../e_core/grid_logic.dart';
import '../e_core/plant_state.dart';
import '../e_core/plant_assets.dart';
import '../e_core/ui_logic.dart';
import '../e_core/waves/wave_controller.dart';
import '../e_core/ui/wave_timer_label.dart';
import '../e_core/ui/wave_warning_popup.dart';
import '../e_core/zombie_assets.dart';
import '../e_core/zombie_spawner.dart';
import '../e_core/behaviors/sun_production.dart';
import '../e_core/behaviors/plant_shooting.dart';
import '../e_core/behaviors/zombie_attack.dart';
import '../e_core/pooling/projectile_pool.dart';
import '../e_core/pooling/zombie_pool.dart';

/// Main Flame game for our simplified Plants vs Zombies.
///
/// Uses the new input API via [TapCallbacks] instead of the deprecated
/// [TapDetector] mixin.
class PvzGame extends FlameGame
    with TapCallbacks, HasHoverables, KeyboardEvents {
  PvzGame();

  /// 2D list holding all tiles so we can find them by [row][col].
  late final List<List<Tile>> tiles;

  /// How much sun the player has.
  late SunBank sunBank;

  /// Currently selected plant card (if any).
  PlantType? selectedPlantType;

  /// Sprites for each plant type, loaded once at startup.
  late Map<PlantType, Sprite> plantSprites;

  /// Sprites for each zombie type, loaded once at startup.
  late ZombieAssets zombieAssets;

  /// Object pool for projectiles.
  late ProjectilePool projectilePool;

  /// Object pool for zombies.
  late ZombiePool zombiePool;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1) Camera & world
    GameLayout.setupCamera(this);

    // 2) Asset folders
    images.prefix = 'assets/images/';

    // 3) Load grass tiles
    final lightTileSprite = await loadSprite(
      'green_tiles/tile_light_green.png',
    );
    final darkTileSprite = await loadSprite('green_tiles/tile_dark_green.png');

    projectilePool = ProjectilePool(game: this);
    zombiePool = ZombiePool(game: this);

    // 4) Build grid
    createGrid(lightTileSprite, darkTileSprite);

    // 5) Plant state (sun + selection)
    initPlantState();

    // 6) Plant sprites
    await loadPlantSprites();

    // 7) Bottom plant selection bar
    createPlantBar();

    // 8) Zombie sprites
    zombieAssets = await ZombieAssets.load(images);

    // 9) Wave controller + UI
    final waveController = WaveController(
      bigWaveInterval: 30,
      regularSpawnInterval: 10,
      minZombiesPerRegularSpawn: 1,
      maxZombiesPerRegularSpawn: 4,
    );
    add(waveController);

    add(WaveTimerLabel());

    final waveWarningPopup = WaveWarningPopup();
    add(waveWarningPopup);

    // UI hook: when a big wave is triggered, show the popup.
    waveController.onBigWave = waveWarningPopup.show;

    // 10) Zombie spawner wired into wave controller
    final zombieSpawner = ZombieSpawner(game: this);

    waveController.onRegularSpawn = zombieSpawner.spawnRegularBatch;
    waveController.onBigWaveSpawn = zombieSpawner.spawnBigWave;

    // 11) Sunflower production system
    add(SunProduction());

    // 12) Plant shooting system
    add(PlantShooting());

    // 13) Zombies explode on plants (attack system).
    add(ZombieAttack());
  }

  @override
  void onTapDown(TapDownEvent event) {
    handleTapDown(event);
  }

  /// Keyboard debug controls:
  /// - Press K: damage all plants by 20.
  /// - Press J: damage all zombies by 20.
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is RawKeyDownEvent) {
      // K -> damage all plants by 20
      if (event.logicalKey == LogicalKeyboardKey.keyK) {
        for (final plant in children.whereType<Plant>()) {
          plant.applyDamage(20);
        }
        // ignore: avoid_print
        print('DEBUG: Damaged all plants by 20');
        return KeyEventResult.handled;
      }

      // J -> damage all zombies by 20
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        for (final zombie in children.whereType<Zombie>()) {
          zombie.applyDamage(20);
        }
        // ignore: avoid_print
        print('DEBUG: Damaged all zombies by 20');
        return KeyEventResult.handled;
      }

      // P -> print projectile pool state
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        projectilePool.debugPrintState();
        return KeyEventResult.handled;
      }

      // O -> print zombie pool state
      if (event.logicalKey == LogicalKeyboardKey.keyO) {
        zombiePool.debugPrintState();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}

mixin HasHoverables {}
