// lib/e_core/ui/game_over_panel.dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show TextStyle, Colors;

import '../../../game/pvz_game.dart';
import '../../patterns/state/game_state.dart';

/// A centered panel that appears when the game is won or lost.
///
/// - Shows a gradient background (green for win, red for lose).
/// - Displays a title ("Congrats, you won!" / "You lost, try again").
/// - Shows the zombie kill score.
/// - Displays two buttons:
///   - If WON: [Next] and [Restart]
///   - If LOST: [Restart] and [Restart]
///
/// The panel uses a Flame scale effect to "pop in" nicely.
class GameOverPanel extends PositionComponent
    with HasGameRef<PvzGame>, TapCallbacks {
  GameOverPanel({this.onRestart, this.onNext})
    : super(priority: 2000); // Draw above normal HUD.

  /// Callback to restart the game (used on both buttons except Next).
  final void Function()? onRestart;

  /// Callback to go to the next difficulty (used on win).
  final void Function()? onNext;

  GameStatus _status = GameStatus.playing;
  int _zombieKills = 0;

  bool _isVisible = false;

  late final TextComponent _titleLabel;
  late final TextComponent _scoreLabel;
  late final _PanelButton _primaryButton;
  late final _PanelButton _secondaryButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Centered panel.
    size = Vector2(320, 200);
    anchor = Anchor.center;
    position = gameRef.size / 2;

    // Start slightly scaled down; we'll animate up when shown.
    scale = Vector2.all(0.8);

    // Title: top-middle.
    _titleLabel = TextComponent(
      text: '',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 24),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Score: under title.
    _scoreLabel = TextComponent(
      text: '',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 64),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );

    // Primary button (left).
    _primaryButton = _PanelButton(label: '', onPressed: _handlePrimaryPressed)
      ..size = Vector2(120, 40)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(size.x / 2 - 70, size.y - 32);

    // Secondary button (right) – always Restart.
    _secondaryButton =
        _PanelButton(label: 'Restart', onPressed: _handleSecondaryPressed)
          ..size = Vector2(120, 40)
          ..anchor = Anchor.bottomCenter
          ..position = Vector2(size.x / 2 + 70, size.y - 32);

    addAll([_titleLabel, _scoreLabel, _primaryButton, _secondaryButton]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Keep the panel centered when the viewport changes.
    position = size / 2;
  }

  /// Show the panel for the given [status] and [zombieKills].
  ///
  /// This triggers a Flame scale effect to make it pop in.
  void show(GameStatus status, int zombieKills) {
    _status = status;
    _zombieKills = zombieKills;
    _isVisible = true;

    _configureContent();
    _playShowAnimation();
  }

  /// Hide the panel.
  void hide() {
    _isVisible = false;
  }

  void _configureContent() {
    // Title + primary button label depend on win/lose.
    if (_status == GameStatus.won) {
      _titleLabel.text = 'Congrats, you won!';
      _primaryButton.setLabel('Next');
    } else if (_status == GameStatus.lost) {
      _titleLabel.text = 'You lost, try again';
      _primaryButton.setLabel('Restart');
    } else {
      _titleLabel.text = '';
      _primaryButton.setLabel('');
    }

    _scoreLabel.text = 'Zombies defeated: $_zombieKills';

    // Secondary button is always "Restart".
    _secondaryButton.setLabel('Quit');
  }

  void _playShowAnimation() {
    // Reset base transform.
    scale = Vector2.all(0.8);

    // Remove previous scale effects if any.
    for (final effect in children.whereType<Effect>().toList()) {
      effect.removeFromParent();
    }

    // Scale up slightly with a quick motion.
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25)));
  }

  void _handlePrimaryPressed() {
    if (!_isVisible) return;

    if (_status == GameStatus.won) {
      // "Next" -> increase difficulty.
      onNext?.call();
    } else if (_status == GameStatus.lost) {
      // "Restart" -> restart with same difficulty.
      onRestart?.call();
    }
  }

  void _handleSecondaryPressed() {
    if (!_isVisible) return;

    // Secondary button is always Restart.
    onRestart?.call();
  }

  /// Ensure that when the panel is hidden, it and its children
  /// are not rendered at all.
  @override
  void renderTree(Canvas canvas) {
    if (!_isVisible) {
      return;
    }
    super.renderTree(canvas);
  }

  /// While the panel is visible, keep the score text in sync with
  /// the game's kill counter.
  @override
  void update(double dt) {
    super.update(dt);

    if (!_isVisible) return;

    // Always sync from the live kill counter in the game (but since kills only
    // count while playing, this will be stable after game over).
    final currentKills = gameRef.killCounter.killCount;
    if (currentKills != _zombieKills) {
      _zombieKills = currentKills;
      _scoreLabel.text = 'Zombies defeated: $_zombieKills';
    }
  }

  @override
  void render(Canvas canvas) {
    // Panel background with vertical gradient depending on win/lose.
    final rect = size.toRect();

    // Use exactly 2 colors for the gradient (top & bottom).
    final gradient = Gradient.linear(
      rect.topCenter,
      rect.bottomCenter,
      _status == GameStatus.won
          ? const [
              Color(0xFF2E7D32), // dark green
              Color(0xFFA5D6A7), // light green
            ]
          : const [
              Color(0xFFC62828), // dark red
              Color(0xFFFFCDD2), // light red
            ],
    );

    final bgPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      bgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      borderPaint,
    );

    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Swallow taps so they don't hit the game world underneath when panel visible.
    if (_isVisible) {
      event.handled = true;
    }
    super.onTapDown(event);
  }
}

/// Simple rectangular button used inside [GameOverPanel].
class _PanelButton extends PositionComponent with TapCallbacks {
  _PanelButton({required String label, required this.onPressed})
    : _labelText = label;

  final void Function()? onPressed;

  String _labelText;

  late final TextComponent _label;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _label = TextComponent(
      text: _labelText,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    add(_label);
  }

  void setLabel(String value) {
    _labelText = value;
    if (isMounted) {
      _label.text = value;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();

    final bgPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      bgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onPressed?.call();
  }
}
