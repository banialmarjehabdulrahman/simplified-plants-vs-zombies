// lib/e_core/ui/game_timer_label.dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show TextStyle, Colors;

import '../../../game/pvz_game.dart';
import '../../patterns/observer/event_bus.dart';
import '../../patterns/state/game_state.dart';

/// Global game countdown timer shown at the top of the screen.
///
/// - Starts from [totalSeconds].
/// - Counts down to 0.
/// - When reaching 0, it stops and calls [onCompleted] (if set) and
///   emits a [WinTimerCompletedEvent] on the [EventBus].
class GameTimerLabel extends TextComponent with HasGameRef<PvzGame> {
  GameTimerLabel({required double totalSeconds, this.onCompleted})
    : _remainingSeconds = totalSeconds,
      super(priority: 1000);

  /// How many seconds are left until the player wins.
  double _remainingSeconds;

  /// Whether the timer is currently running.
  bool _isRunning = true;

  /// Optional callback fired once when the timer reaches 0.
  final void Function()? onCompleted;

  double get remainingSeconds => _remainingSeconds;

  final EventBus _bus = EventBus.instance; // NEW

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Anchor in the top-center; actual position is set in _updatePosition.
    anchor = Anchor.topCenter;

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    _updatePosition(gameRef.size); // position based on current size
    _updateText();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updatePosition(size);
  }

  void _updatePosition(Vector2 size) {
    // Top-center with a little vertical margin.
    position = Vector2(size.x / 2, 16);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isRunning || _remainingSeconds <= 0) {
      return;
    }

    _remainingSeconds -= dt;

    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _isRunning = false;
      _updateText();

      // Emit high-level win event so GameStateManager can mark the game as won.
      _bus.emit(const WinTimerCompletedEvent());
      // ignore: avoid_print
      print('GameTimerLabel: timer completed, emitting WinTimerCompletedEvent');

      // Optional external callback hook.
      onCompleted?.call();
    } else {
      _updateText();
    }
  }

  /// Reset the timer to [newTotalSeconds] (or the current remaining time
  /// if not provided) and start running again.
  void reset({double? newTotalSeconds}) {
    if (newTotalSeconds != null) {
      _remainingSeconds = newTotalSeconds;
    }
    _isRunning = true;
    _updateText();
  }

  void _updateText() {
    final totalSecondsInt = _remainingSeconds.floor().clamp(0, 3599);
    final minutes = totalSecondsInt ~/ 60;
    final seconds = totalSecondsInt % 60;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    text = '$minutesStr:$secondsStr';
  }
}
