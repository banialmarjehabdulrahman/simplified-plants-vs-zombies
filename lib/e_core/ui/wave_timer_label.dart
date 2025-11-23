import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../a_game/pvz_game.dart';
import '../waves/wave_controller.dart';

/// Simple UI label that shows the time remaining
/// until the next big zombie wave.
///
/// Appears in the top-right corner of the screen.
class WaveTimerLabel extends TextComponent with HasGameRef<PvzGame> {
  WaveTimerLabel()
    : super(
        text: '',
        textRenderer: _textPaint,
        priority: 1000, // draw above most things
      );

  static final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  WaveController? _waveController;

  @override
  void onMount() {
    super.onMount();

    anchor = Anchor.topRight;

    // Debug to confirm it's mounting.
    // ignore: avoid_print
    print('WaveTimerLabel mounted');

    _findWaveController();

    text = 'Next big wave: --s';

    // Position once here in case size is already known.
    _updatePosition(gameRef.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updatePosition(size);
  }

  void _updatePosition(Vector2 size) {
    // Top-right corner with padding.
    position = Vector2(size.x - 16, 16);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // In case WaveController was added after this label,
    // keep trying to find it until we succeed.
    _waveController ??= _findWaveController();

    final controller = _waveController;
    if (controller == null) {
      text = 'Next big wave: --s';
      return;
    }

    double remaining = controller.timeUntilNextBigWave;
    if (remaining < 0) remaining = 0;

    final seconds = remaining.ceil();
    text = 'Next big wave: ${seconds.toString().padLeft(2, '0')}s';
  }

  WaveController? _findWaveController() {
    for (final child in gameRef.children) {
      if (child is WaveController) {
        // ignore: avoid_print
        print('WaveTimerLabel found WaveController');
        return child;
      }
    }
    return null;
  }
}
