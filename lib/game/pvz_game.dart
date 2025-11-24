// lib/a_game/pvz_game.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/assets/plant_assets.dart';
import '../core/assets/zombie_assets.dart';
import '../core/audio/audio_manager.dart';
import '../core/game/config/game_layout.dart';
import '../core/game/config/grid_logic.dart';
import '../core/game/logic/game_over_controller.dart';
import '../core/game/logic/plant_state.dart';
import '../core/game/logic/player_health.dart';
import '../core/game/logic/ui_logic.dart';
import '../core/game/logic/zombie_kill_counter.dart';
import '../core/game/logic/zombie_spawner.dart';
import '../core/patterns/object_pool/projectile_pool.dart';
import '../core/patterns/object_pool/zombie_pool.dart';
import '../core/patterns/state/game_state.dart';
import '../core/ui/hud/game_timer_label.dart';
import '../core/ui/hud/wave_timer_label.dart';
import '../core/ui/hud/wave_warning_popup.dart';
import '../core/waves/wave_controller.dart';
import '../domain/behaviors/plant_shooting.dart';
import '../domain/behaviors/sun_production.dart';
import '../domain/behaviors/zombie_attack.dart';
import '../domain/components/plant.dart';
import '../domain/components/tile.dart';
import '../domain/components/zombie.dart';
import '../domain/models/plant_type.dart';

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

  /// Handles high-level win/lose detection and broadcasts game status events.
  late final GameStateManager gameStateManager;

  /// Shows the end-of-game panel when the player wins or loses.
  late final GameOverController gameOverController;

  /// Handles player hearts (lives) and hearts HUD.
  late final PlayerHealth playerHealth;

  /// Tracks how many zombies have been killed this run.
  late final ZombieKillCounter killCounter;

  /// Global countdown timer for win condition UI.
  late final GameTimerLabel gameTimer;

  /// Whether we've started background music yet (to satisfy browser autoplay).
  bool _hasStartedBgm = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1) Camera & world
    GameLayout.setupCamera(this);

    // 2) Asset folders
    images.prefix = 'assets/images/';

    // 3) Audio initialization (one-time).
    // We DO NOT start background music here because browsers (especially web)
    // often block autoplay with sound until the user interacts.
    await AudioManager.instance.init();

    // 4) Load grass tiles
    final lightTileSprite = await loadSprite(
      'green_tiles/tile_light_green.png',
    );
    final darkTileSprite = await loadSprite('green_tiles/tile_dark_green.png');

    projectilePool = ProjectilePool(game: this);
    zombiePool = ZombiePool(game: this);

    // 5) Build grid
    createGrid(lightTileSprite, darkTileSprite);

    // 6) Plant state (sun + selection)
    initPlantState();

    // 7) Plant sprites
    await loadPlantSprites();

    // 8) Bottom plant selection bar
    createPlantBar();

    // 9) Zombie sprites
    zombieAssets = await ZombieAssets.load(images);

    // 10) Wave controller + UI
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

    // 11) Zombie spawner wired into wave controller
    final zombieSpawner = ZombieSpawner(game: this);

    waveController.onRegularSpawn = zombieSpawner.spawnRegularBatch;
    waveController.onBigWaveSpawn = zombieSpawner.spawnBigWave;

    // 12) Sunflower production system
    add(SunProduction());

    // 13) Plant shooting system
    add(PlantShooting());

    // 14) Zombies explode on plants (attack system).
    add(ZombieAttack());

    // 15) Game state manager (win/lose detection via events).
    gameStateManager = GameStateManager();
    add(gameStateManager);

    // 16) Kill counter for zombies.
    killCounter = ZombieKillCounter();
    add(killCounter);

    // 17) Game over controller (shows win/lose panel).
    gameOverController = GameOverController();
    add(gameOverController);

    // 18) Player health (lives) system and HUD
    playerHealth = PlayerHealth(maxLives: 3);
    add(playerHealth);

    // 19) Win countdown timer.
    gameTimer = GameTimerLabel(
      totalSeconds: 60, // adjust as you like
    );
    add(gameTimer);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Start BGM the first time the player interacts with the game.
    if (!_hasStartedBgm) {
      _hasStartedBgm = true;
      AudioManager.instance.playBackgroundMusic();
    }

    handleTapDown(event);
  }

  /// Keyboard debug controls:
  /// - Press K: damage all plants by 20.
  /// - Press J: damage all zombies by 20.
  /// - Press P: print projectile pool state.
  /// - Press O: print zombie pool state.
  /// - Press M: skip to next BGM track.
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // We only care about key *down* events (not key up / repeat).
    final isDown = event is KeyDownEvent || event is RawKeyDownEvent;
    if (!isDown) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // Global debug: see which key was pressed.
    // ignore: avoid_print
    print('DEBUG: Key down -> ${key.debugName}');

    // K -> damage all plants by 20
    if (key == LogicalKeyboardKey.keyK) {
      for (final plant in children.whereType<Plant>()) {
        plant.applyDamage(20);
      }
      // ignore: avoid_print
      print('DEBUG: Damaged all plants by 20');
      return KeyEventResult.handled;
    }

    // J -> damage all zombies by 20
    if (key == LogicalKeyboardKey.keyJ) {
      for (final zombie in children.whereType<Zombie>()) {
        zombie.applyDamage(20);
      }
      // ignore: avoid_print
      print('DEBUG: Damaged all zombies by 20');
      return KeyEventResult.handled;
    }

    // P -> print projectile pool state
    if (key == LogicalKeyboardKey.keyP) {
      projectilePool.debugPrintState();
      return KeyEventResult.handled;
    }

    // O -> print zombie pool state
    if (key == LogicalKeyboardKey.keyO) {
      zombiePool.debugPrintState();
      return KeyEventResult.handled;
    }

    // M -> skip to next background music track (debug)
    if (key == LogicalKeyboardKey.keyM) {
      // ignore: avoid_print
      print('DEBUG: Skipping to next BGM track');
      AudioManager.instance.playNextTrack();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

mixin HasHoverables {}
