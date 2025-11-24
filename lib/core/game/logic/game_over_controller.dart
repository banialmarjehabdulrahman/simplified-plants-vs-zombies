// lib/core/game/logic/game_over_controller.dart
import 'package:flame/components.dart';

import '../../../domain/components/plant.dart';
import '../../../domain/components/projectile.dart';
import '../../../domain/components/zombie.dart';
import '../../../game/pvz_game.dart';
import '../../audio/audio_manager.dart';
import '../../patterns/state/game_state.dart';
import '../../ui/overlays/game_over_panel.dart';

/// Watches [GameStateManager] and shows the [GameOverPanel] when the
/// player wins or loses.
///
/// Core systems (health, timer) communicate via EventBus to the
/// [GameStateManager]; this controller just observes the current
/// [GameStatus] from the game and handles UI, and also handles simple
/// restart / next-difficulty logic.
class GameOverController extends Component with HasGameRef<PvzGame> {
  GameOverController();

  late final GameOverPanel _panel;

  /// Last status we reacted to, so we only update the panel when it changes.
  GameStatus _lastStatus = GameStatus.playing;

  /// Base survival time in seconds for difficulty level 1.
  static const double _baseWinTimeSeconds = 60.0;

  /// Current difficulty level. Level 1 = 60s, level 2 = 120s, etc.
  int _difficultyLevel = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create the panel and add it to the game. It starts hidden.
    _panel = GameOverPanel(onRestart: _handleRestart, onNext: _handleNext);

    gameRef.add(_panel);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final currentStatus = gameRef.gameStateManager.status;

    if (currentStatus == _lastStatus) {
      return; // nothing changed
    }

    _lastStatus = currentStatus;

    if (currentStatus == GameStatus.playing) {
      _panel.hide();
      return;
    }

    // Use the real zombie kill count from the game's kill counter.
    final zombieKills = gameRef.killCounter.killCount;

    _panel.show(currentStatus, zombieKills);

    // Play appropriate win/lose SFX once when status changes.
    if (currentStatus == GameStatus.won) {
      AudioManager.instance.playGameWin();
    } else if (currentStatus == GameStatus.lost) {
      AudioManager.instance.playGameLose();
    }
  }

  void _handleRestart() {
    // Restart with the same difficulty level.
    // ignore: avoid_print
    print('GameOverController: Restart pressed');
    _restartGame(keepDifficulty: true);
  }

  void _handleNext() {
    // Increase difficulty (longer survival time) and restart.
    // ignore: avoid_print
    print('GameOverController: Next (harder) pressed');
    _difficultyLevel++;
    _restartGame(keepDifficulty: false);
  }

  /// Reset core game state for a new run.
  ///
  /// [keepDifficulty] = true -> reuse current difficulty
  /// [keepDifficulty] = false -> use updated [_difficultyLevel] value.
  void _restartGame({required bool keepDifficulty}) {
    // Compute new survival time based on difficulty.
    final level = _difficultyLevel;
    final newWinTime = _baseWinTimeSeconds * level;

    // 0) Make sure the Flame engine is running again in case it was paused
    //    by the UI / pause menu.
    // Calling this is safe even if the engine is already running.
    gameRef.resumeEngine();

    // 1) Clear gameplay entities from the board.

    // a) Recycle all active zombies into the pool.
    for (final zombie in gameRef.children.whereType<Zombie>().toList()) {
      gameRef.zombiePool.release(zombie);
    }

    // b) Recycle all active projectiles into the pool.
    for (final projectile
        in gameRef.children.whereType<Projectile>().toList()) {
      gameRef.projectilePool.release(projectile);
    }

    // c) Remove all plants from the grid.
    for (final plant in gameRef.children.whereType<Plant>().toList()) {
      plant.removeFromParent();
    }

    // d) Clear tile occupancy flags so we can place again.
    for (final row in gameRef.tiles) {
      for (final tile in row) {
        tile.hasPlant = false;
      }
    }

    // 2) Reset score, hearts, sun, and timer.
    gameRef.killCounter.reset();
    gameRef.playerHealth.reset();

    // Reset sun bank & selected plant.
    gameRef.sunBank.current = 150;
    gameRef.selectedPlantType = null;

    gameRef.gameTimer.reset(newTotalSeconds: newWinTime);

    // 3) Reset game status to "playing" using the State pattern.
    gameRef.gameStateManager.resetToPlaying();
    _lastStatus = GameStatus.playing;

    // 4) Hide the panel.
    _panel.hide();

    // Debug info.
    // ignore: avoid_print
    print(
      'GameOverController: game restarted at difficulty level $level '
      'with win timer = ${newWinTime.toStringAsFixed(0)}s',
    );
  }
}
