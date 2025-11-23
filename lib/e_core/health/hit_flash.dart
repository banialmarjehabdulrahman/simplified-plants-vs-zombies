import 'dart:math' show sin;
import 'package:flutter/material.dart';

/// Handles a brief "hit flash" effect (red/yellow flicker) after taking damage.
///
/// Purely visual: call [trigger] when damage is applied,
/// [update] every frame, and read [currentColor] to apply to the sprite.
class HitFlashEffect {
  HitFlashEffect({
    required this.duration,
    this.baseColor = Colors.white,
    this.flashColorA = const Color.fromARGB(255, 54, 82, 244),
    this.flashColorB = const Color.fromARGB(255, 255, 59, 59),
    this.flashFrequency = 12.0, // 12 toggles per second
  }) : assert(duration >= 0, 'duration must be >= 0');

  /// Total time the flash lasts after a hit.
  final double duration;

  /// Normal color when not flashing.
  final Color baseColor;

  /// First flash color (e.g. red).
  final Color flashColorA;

  /// Second flash color (e.g. yellow).
  final Color flashColorB;

  /// How fast we alternate colors (cycles per second).
  final double flashFrequency;

  double _remaining = 0.0;
  double _elapsed = 0.0;

  /// True while the flash effect is active.
  bool get isActive => _remaining > 0.0;

  /// Start (or restart) the flash effect.
  void trigger() {
    if (duration <= 0) return;
    _remaining = duration;
    _elapsed = 0.0;
  }

  /// Advance the timers. Call once per frame.
  void update(double dt) {
    if (_remaining <= 0) return;
    _remaining -= dt;
    _elapsed += dt;
    if (_remaining < 0) {
      _remaining = 0;
    }
  }

  /// Current color you should apply to the sprite.
  Color get currentColor {
    if (!isActive) return baseColor;

    // Simple, strong flicker: red <-> yellow
    final phase = (_elapsed * flashFrequency).floor();
    final useA = phase.isEven;
    return useA ? flashColorA : flashColorB;
  }

  /// Stop the effect immediately.
  void reset() {
    _remaining = 0.0;
    _elapsed = 0.0;
  }
}
