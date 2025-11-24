// lib/e_core/game_state.dart
import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';
import '../observer/event_bus.dart';

/// High-level game state for the current session.
enum GameStatus { playing, won, lost }

/// Event emitted when the player has no lives left.
class LivesDepletedEvent {
  const LivesDepletedEvent();
}

/// Event emitted when the win timer reaches zero.
class WinTimerCompletedEvent {
  const WinTimerCompletedEvent();
}

/// Event emitted whenever the high-level [GameStatus] changes.
class GameStatusChangedEvent {
  const GameStatusChangedEvent(this.status);

  final GameStatus status;
}

/// --- State pattern core -----------------------------------------------

/// Abstract base for all concrete game states.
///
/// Each concrete state decides how to react to high-level events like
/// "lives depleted" or "win timer completed".
abstract class GameState {
  GameStatus get status;

  /// Called when this state becomes active.
  void onEnter(GameStateManager manager) {}

  /// Called when this state is replaced by another state.
  void onExit(GameStateManager manager) {}

  /// Player ran out of lives.
  void onLivesDepleted(GameStateManager manager) {}

  /// Win timer reached zero.
  void onWinTimerCompleted(GameStateManager manager) {}
}

/// Normal gameplay: the player is still playing.
class PlayingState extends GameState {
  @override
  GameStatus get status => GameStatus.playing;

  @override
  void onEnter(GameStateManager manager) {
    // ignore: avoid_print
    print('GameStateManager: entered PLAYING state');
  }

  @override
  void onLivesDepleted(GameStateManager manager) {
    // Transition to "lost" once lives are gone.
    manager.transitionTo(LostState());
  }

  @override
  void onWinTimerCompleted(GameStateManager manager) {
    // Transition to "won" when the player survives long enough.
    manager.transitionTo(WonState());
  }
}

/// Terminal state: the player has won.
class WonState extends GameState {
  @override
  GameStatus get status => GameStatus.won;

  @override
  void onEnter(GameStateManager manager) {
    // ignore: avoid_print
    print('GameStateManager: entered WON state');
  }
}

/// Terminal state: the player has lost.
class LostState extends GameState {
  @override
  GameStatus get status => GameStatus.lost;

  @override
  void onEnter(GameStateManager manager) {
    // ignore: avoid_print
    print('GameStateManager: entered LOST state');
  }
}

/// Component that listens to high-level game events via [EventBus] and
/// delegates to the current [GameState] instance.
///
/// External systems should read [status] to know if the game is
/// [GameStatus.playing], [GameStatus.won], or [GameStatus.lost].
class GameStateManager extends Component with HasGameRef<PvzGame> {
  GameStateManager();

  final EventBus _bus = EventBus.instance;

  late GameState _state;

  /// Expose the current status (for UI, zombies, controllers, etc.).
  GameStatus get status => _state.status;

  EventSubscription? _livesSub;
  EventSubscription? _timerSub;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Start in PLAYING state.
    _state = PlayingState();
    _state.onEnter(this);

    // Listen for "lives depleted" and "timer completed" events.
    _livesSub = _bus.subscribe<LivesDepletedEvent>((event) {
      _state.onLivesDepleted(this);
    });

    _timerSub = _bus.subscribe<WinTimerCompletedEvent>((event) {
      _state.onWinTimerCompleted(this);
    });
  }

  /// Core State-pattern transition method.
  ///
  /// [force] bypasses the usual "ignore transitions after win/lose" rule,
  /// which is useful when restarting the game.
  void transitionTo(GameState newState, {bool force = false}) {
    // If already in a terminal state (won or lost), ignore further
    // transitions unless we're explicitly forcing (e.g. on restart).
    if (!force && _state.status != GameStatus.playing) {
      // ignore: avoid_print
      print(
        'GameStateManager: ignoring transition to ${newState.status} '
        'because game is already ${_state.status}',
      );
      return;
    }

    // If the status wouldn't change, skip.
    if (!force && newState.status == _state.status) {
      return;
    }

    _state.onExit(this);
    _state = newState;
    _state.onEnter(this);

    // Broadcast a "status changed" event so other systems can react.
    _bus.emit(GameStatusChangedEvent(_state.status));

    // ignore: avoid_print
    print('GameStateManager: status changed to ${_state.status}');
  }

  /// Used by the game-over controller when the player presses Restart/Next.
  void resetToPlaying() {
    transitionTo(PlayingState(), force: true);
  }

  @override
  void onRemove() {
    _livesSub?.cancel();
    _timerSub?.cancel();
    super.onRemove();
  }
}
