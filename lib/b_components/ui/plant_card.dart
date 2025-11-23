import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show TextStyle, Colors;

import '../../a_game/pvz_game.dart';
import '../../d_models/plant_type.dart';
import '../../e_core/plant_state.dart';

/// One selectable plant card in the bottom bar.
///
/// Shows plant icon, sun cost, and name.
/// When clicked, selects that plant type.
class PlantCard extends PositionComponent
    with TapCallbacks, HoverCallbacks, HasGameRef<PvzGame> {
  PlantCard({
    required this.definition,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  /// Which plant this card represents.
  final PlantDefinition definition;

  Sprite? _iconSprite;
  late final TextComponent _costLabel;
  late final TextComponent _nameLabel;

  Effect? _hoverEffect;

  bool get _isSelected => gameRef.isPlantSelected(definition.type);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load plant icon sprite. Path is relative to images.prefix.
    _iconSprite = await gameRef.loadSprite(definition.iconPath);

    // Cost label: "100 ☀"
    _costLabel = TextComponent(
      text: '${definition.cost} ☀',
      position: Vector2(size.x / 2, size.y * 0.55),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellow, fontSize: 12),
      ),
    );

    // Name label: "Peashooter"
    _nameLabel = TextComponent(
      text: definition.name,
      position: Vector2(size.x / 2, size.y * 0.78),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );

    addAll([_costLabel, _nameLabel]);
  }

  // ---------- Hover animation ----------

  void _applyHoverScale(double targetScale) {
    // remove previous effect if still active
    _hoverEffect?.removeFromParent();
    _hoverEffect = ScaleEffect.to(
      Vector2.all(targetScale),
      EffectController(duration: 0.1),
    );
    add(_hoverEffect!);
  }

  @override
  void onHoverEnter() {
    _applyHoverScale(1.05); // small pop-up
  }

  @override
  void onHoverExit() {
    _applyHoverScale(1.0); // back to normal
  }

  // ---------- Rendering ----------

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();

    // Card background
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF222222);
    canvas.drawRect(rect, bgPaint);

    // Border (yellowish when selected, orange otherwise)
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _isSelected ? const Color(0xFFFFD54F) : const Color(0xFFFFA000);
    canvas.drawRect(rect, borderPaint);

    // Icon sprite (top part of the card)
    if (_iconSprite != null) {
      final iconSize = Size(size.x * 0.6, size.y * 0.45);
      final iconRect = Rect.fromLTWH(
        rect.left + (rect.width - iconSize.width) / 2,
        rect.top + 8,
        iconSize.width,
        iconSize.height,
      );
      _iconSprite!.renderRect(canvas, iconRect);
    }
  }

  // ---------- Tap handling ----------

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    gameRef.selectPlant(definition);
  }
}
