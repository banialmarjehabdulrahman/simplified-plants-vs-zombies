import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class PvzGame extends FlameGame {
  PvzGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));

    add(
      TestBox()
        ..position = Vector2(100, 280)
        ..size = Vector2(50, 50),
    );
  }
}

class TestBox extends PositionComponent {
  TestBox();

  double speed = 150;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(rect, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    x += speed * dt;

    if (x > 800) {
      x = -size.x;
    }
  }
}
