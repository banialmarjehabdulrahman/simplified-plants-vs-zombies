// lib/e_core/ui/lives_display.dart
import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';

/// Simple HUD element that shows the player's remaining lives as heart sprites
/// in the top-left corner of the screen.
///
/// It does *not* manage the actual life logic; it only renders whatever
/// value is passed in via [setLives].
class LivesDisplay extends PositionComponent with HasGameRef<PvzGame> {
  LivesDisplay({int initialLives = 3})
    : _lives = initialLives,
      super(priority: 1000);

  /// Current lives value mirrored from the game logic.
  int _lives;

  /// Heart icons currently displayed.
  final List<SpriteComponent> _heartIcons = [];

  /// Heart sprite loaded once in [onLoad].
  Sprite? _heartSprite;

  /// Maximum number of hearts we support visually.
  static const int maxHearts = 3;

  static const double _heartSize = 24.0;
  static const double _spacing = 4.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // HUD anchor in the top-left; actual screen position will be set
    // in _updatePosition / onGameResize.
    anchor = Anchor.topLeft;

    try {
      // Make sure you have this path in pubspec:
      // assets:
      //   - assets/images/ui/heart.png
      _heartSprite = await gameRef.loadSprite('ui/heart.png');
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('LivesDisplay: failed to load heart sprite: $e');
      // ignore: avoid_print
      print(stackTrace);
      return;
    }

    _updatePosition(gameRef.size);
    _rebuildHearts();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updatePosition(size);
  }

  void _updatePosition(Vector2 size) {
    // Always stick to the top-left corner of the screen with some padding.
    position = Vector2(16, 16);
  }

  /// Update the HUD to reflect the current number of lives.
  ///
  /// This does not enforce any game rules; callers are responsible for
  /// clamping the life value according to their game logic.
  void setLives(int value) {
    if (value == _lives) {
      return;
    }

    _lives = value.clamp(0, maxHearts).toInt();
    _rebuildHearts();
  }

  void _rebuildHearts() {
    if (_heartSprite == null) {
      return; // sprite failed to load or onLoad not finished yet
    }

    // Remove old icons from the component tree.
    for (final heart in _heartIcons) {
      heart.removeFromParent();
    }
    _heartIcons.clear();

    // Add one icon per current life.
    for (var i = 0; i < _lives; i++) {
      final heart = SpriteComponent(
        sprite: _heartSprite!,
        size: Vector2.all(_heartSize),
        position: Vector2(i * (_heartSize + _spacing), 0),
      );

      _heartIcons.add(heart);
      add(heart);
    }
  }
}
