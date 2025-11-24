import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// A small hit flash that appears on top of a plant when a zombie bites it.
/// Uses Flame Effects (ScaleEffect) and then removes itself.
class PlantHitEffect extends PositionComponent {
  PlantHitEffect({required Vector2 worldPosition})
    : super(
        position: worldPosition.clone(),
        size: Vector2.all(24),
        anchor: Anchor.center,
        priority: 900, // on top of plants
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Simple red/orange circle.
    final circle = CircleComponent(
      radius: size.x / 2,
      paint: Paint()
        ..color = const Color.fromARGB(255, 234, 0, 255).withOpacity(0.9),
      anchor: Anchor.center,
    );
    add(circle);

    // Scale up a bit then stop (Flame Effect).
    add(ScaleEffect.to(Vector2.all(1.6), EffectController(duration: 0.15)));

    // Auto-remove after a short delay.
    add(
      TimerComponent(
        period: 0.2,
        repeat: false,
        onTick: () => removeFromParent(),
      ),
    );
  }
}
