import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../a_game/pvz_game.dart';

/// Popup text shown when a big zombie wave is incoming.
///
/// Appears at the top-center, scales down and fades out,
/// then hides itself. Designed to be reusable (no destroy).
class WaveWarningPopup extends TextComponent with HasGameRef<PvzGame> {
  WaveWarningPopup()
    : super(
        text: '',
        textRenderer: _baseRenderer,
        priority: 1001, // above most things, including timer
      );

  static const double _duration = 2.5; // seconds for full animation
  static const double _startScale = 1.4;
  static const double _endScale = 0.8;

  static const TextStyle _baseStyle = TextStyle(
    color: Colors.red,
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static final TextPaint _baseRenderer = TextPaint(style: _baseStyle);

  double _elapsed = 0.0;
  bool _isActive = false;

  @override
  void onMount() {
    super.onMount();

    anchor = Anchor.topCenter;
    _updatePosition(gameRef.size);
    _hide();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updatePosition(size);
  }

  void _updatePosition(Vector2 size) {
    // Top-center with some padding downward.
    position = Vector2(size.x / 2, 40);
  }

  /// Show the popup and restart its animation.
  void show() {
    _elapsed = 0.0;
    _isActive = true;
    text = 'Zombie wave is incoming!';
    scale = Vector2.all(_startScale);
    textRenderer = _baseRenderer;
  }

  /// Hide the popup (used when animation finishes and for reuse).
  void _hide() {
    _isActive = false;
    text = '';
    scale = Vector2.all(1.0);
    textRenderer = _baseRenderer;
  }

  /// Can be called from an object pool reset later if needed.
  void resetForReuse() {
    _hide();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    _elapsed += dt;
    final t = (_elapsed / _duration).clamp(0.0, 1.0);

    // Scale from large to smaller over time.
    final currentScale = _startScale + (_endScale - _startScale) * t;
    scale.setValues(currentScale, currentScale);

    // Fade out over time.
    final alpha = 1.0 - t;
    final baseColor = _baseStyle.color ?? Colors.red;
    final color = baseColor.withOpacity(alpha);
    textRenderer = TextPaint(style: _baseStyle.copyWith(color: color));

    if (_elapsed >= _duration) {
      _hide();
    }
  }
}
