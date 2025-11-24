// lib/e_core/zombie_kill_counter.dart
import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';
import '../../patterns/observer/event_bus.dart';

/// Event emitted whenever a zombie is killed.
class ZombieKilledEvent {
  const ZombieKilledEvent();
}

/// Tracks total zombies killed in the current game session.
class ZombieKillCounter extends Component with HasGameRef<PvzGame> {
  final EventBus _bus = EventBus.instance;

  int _killCount = 0;
  int get killCount => _killCount;

  @override
  void onMount() {
    super.onMount();

    // Listen to kill events emitted by zombie objects.
    _bus.subscribe<ZombieKilledEvent>((event) {
      _killCount++;
      // ignore: avoid_print
      print('ZombieKillCounter: killCount = $_killCount');
    });
  }

  /// Registers a kill (called directly by Zombie._handleDeath).
  void registerKill() {
    _killCount++;
    // ignore: avoid_print
    print('ZombieKillCounter: killCount = $_killCount');
  }

  /// Reset score (called on restart / next difficulty).
  void reset() {
    _killCount = 0;
  }
}
