import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    as m
    show LinearGradient, Alignment, Colors;

import '../../a_game/pvz_game.dart';
import '../../d_models/plant_type.dart';
import 'plant_card.dart';

/// Background bar that holds all plant cards at the bottom of the screen.
class PlantBar extends PositionComponent with HasGameRef<PvzGame> {
  PlantBar({required this.worldWidth, required this.worldHeight}) {
    const bottomMargin = 10.0;
    const sideMarginLeft = 5.0;
    const sideMarginRight = 1360; // extra big margin on the right

    size = Vector2(worldWidth - sideMarginLeft - sideMarginRight, _barHeight);
    position = Vector2(sideMarginLeft, worldHeight - _barHeight - bottomMargin);
  }

  static const double _barHeight = 200;

  final double worldWidth;
  final double worldHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const cardWidth = 100.0;
    const cardHeight = 110.0;
    const spacing = 24.0;

    final defs = PlantDefinition.all;

    // Total width of all cards + spacing between them.
    final totalWidth = defs.length * cardWidth + (defs.length - 1) * spacing;

    // Center horizontally within the bar.
    double startX = (size.x - totalWidth) / 2;

    // Center vertically within the bar.
    final y = (size.y - cardHeight) / 2;

    for (final def in defs) {
      final card = PlantCard(
        definition: def,
        position: Vector2(startX, y),
        size: Vector2(cardWidth, cardHeight),
      );
      add(card);
      startX += cardWidth + spacing;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the bar starting at (0,0) in local coordinates
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Nice vertical gradient.
    final gradient = m.LinearGradient(
      colors: [m.Colors.black87, m.Colors.green.shade700],
      begin: m.Alignment.topCenter,
      end: m.Alignment.bottomCenter,
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFFFF5252);

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }
}
