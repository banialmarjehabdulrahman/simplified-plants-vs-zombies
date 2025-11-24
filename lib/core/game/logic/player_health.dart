// lib/e_core/player_health.dart
import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';
import '../../patterns/observer/event_bus.dart';
import '../../patterns/state/game_state.dart';
import '../../ui/hud/lives_display.dart';

/// Handles player lives (hearts) and keeps the UI in sync.
///
/// This component owns the lives counter and the [LivesDisplay] HUD.
/// It does *not* render any text itself; it only updates the hearts.
/// When lives reach 0, it emits a [LivesDepletedEvent] on the [EventBus].
class PlayerHealth extends Component with HasGameRef<PvzGame> {
  PlayerHealth({this.maxLives = 3});

  /// Maximum lives (hearts) the player starts with.
  final int maxLives;

  /// Current lives remaining.
  int _currentLives = 0;

  late LivesDisplay _livesDisplay;

  int get currentLives => _currentLives;

  final EventBus _bus = EventBus.instance; // NEW

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _currentLives = maxLives;

    // Create and add the hearts HUD to the game.
    _livesDisplay = LivesDisplay(initialLives: maxLives);
    gameRef.add(_livesDisplay);
  }

  /// Decrease lives by one and update the HUD.
  ///
  /// Does not go below zero.
  /// When lives reach zero for the first time, emits [LivesDepletedEvent].
  void loseLife() {
    if (_currentLives <= 0) {
      return;
    }

    _currentLives -= 1;
    _livesDisplay.setLives(_currentLives);

    // ignore: avoid_print
    print('PlayerHealth: life lost, remaining = $_currentLives / $maxLives');

    if (_currentLives <= 0) {
      _currentLives = 0;
      // Emit a high-level event so GameStateManager can mark the game as lost.
      _bus.emit(const LivesDepletedEvent());
      // ignore: avoid_print
      print('PlayerHealth: lives depleted, emitting LivesDepletedEvent');
    }
  }

  /// Reset lives back to [maxLives] and refresh the HUD.
  void reset() {
    _currentLives = maxLives;
    _livesDisplay.setLives(_currentLives);
  }
}
