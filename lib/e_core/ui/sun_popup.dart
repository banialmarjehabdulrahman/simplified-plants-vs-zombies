import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A small floating popup that shows "+<amount>" and a sun icon,
/// then fades out and removes itself.
class SunPopup extends PositionComponent {
  SunPopup({required this.amount, required Vector2 worldPosition})
    : super(
        position: worldPosition.clone(),
        priority: 1000, // draw on top of most things
      );

  final int amount;

  static const double _lifetime = 2.0; // seconds
  static const double _riseDistance = 40; // pixels total

  double _elapsed = 0.0;

  late final TextComponent _text;
  late final CircleComponent _icon;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create a small yellow "sun" circle as icon (no sprite needed).
    _icon = CircleComponent(
      radius: 8,
      paint: Paint()..color = Colors.yellow,
      anchor: Anchor.center,
      position: Vector2.zero(),
    );

    // Text: "+150"
    _text = TextComponent(
      text: '+$amount',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(14, 0),
    );

    // We'll treat this component's local origin as the center of the icon.
    add(_icon);
    add(_text);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    final t = (_elapsed / _lifetime).clamp(0.0, 1.0);

    // Move up over time.
    final dy = -_riseDistance * t;
    position.y += dy * dt * (1 / (1 / 60)); // normalize a bit for frame rate

    // Fade out towards the end.
    final alpha = 1.0 - t;
    final color = Colors.yellow.withOpacity(alpha);

    _icon.paint.color = color;
    _text.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(alpha),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    if (_elapsed >= _lifetime) {
      removeFromParent();
    }
  }
}
