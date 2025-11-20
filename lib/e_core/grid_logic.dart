import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../a_game/pvz_game.dart';
import '../b_components/tile.dart';
import 'game_layout.dart';

/// All grid-related logic for [PvzGame] is grouped here as an extension.
/// Keeps PvzGame itself smaller and easier to read.
extension GridLogic on PvzGame {
  /// Creates the lawn grid and stores tiles in [tiles].
  void createGrid(Sprite light, Sprite dark) {
    const startX = 0.0; // start at left edge
    const startY = GameLayout.verticalMargin; // push grid down a bit

    // Initialize the 2D list: one inner list per row.
    tiles = List.generate(GameLayout.rows, (_) => <Tile>[]);

    for (var row = 0; row < GameLayout.rows; row++) {
      for (var col = 0; col < GameLayout.cols; col++) {
        // Alternate between light and dark tiles (checkerboard pattern).
        final isLight = (row + col) % 2 == 0;
        final sprite = isLight ? light : dark;

        // Position of the tile in world coordinates.
        final position = Vector2(
          startX + col * GameLayout.tileSize,
          startY + row * GameLayout.tileSize,
        );

        final tile = Tile(
          sprite: sprite,
          position: position,
          size: Vector2.all(GameLayout.tileSize),
          gridX: col,
          gridY: row,
        );

        tiles[row].add(tile);
        add(tile);
      }
    }
  }

  /// Handles tap/clicks on the game and figures out which tile was tapped.
  void handleTapDown(TapDownEvent event) {
    // In the root game, localPosition is in world coordinates.
    final worldPos = event.localPosition;

    // World X maps directly to column index.
    final col = (worldPos.x / GameLayout.tileSize).floor();

    // For Y we subtract the top margin, then divide by tile size.
    final row = ((worldPos.y - GameLayout.verticalMargin) / GameLayout.tileSize)
        .floor();

    // Ignore taps outside the grid.
    final inX = col >= 0 && col < GameLayout.cols;
    final inY = row >= 0 && row < GameLayout.rows;
    if (!inX || !inY) {
      return;
    }

    final tile = tiles[row][col];

    // Visual feedback so the user can see which tile was tapped.
    _highlightTile(tile);

    // Debug log for now; later this will drive plant placement.
    // ignore: avoid_print
    print('Tapped tile row=$row col=$col');
  }

  /// Adds a quick flash effect to the given [tile] using Flame's effects system.
  void _highlightTile(Tile tile) {
    tile.add(
      SequenceEffect([
        OpacityEffect.to(0.5, EffectController(duration: 0.05)),
        OpacityEffect.to(1.0, EffectController(duration: 0.05)),
      ]),
    );
  }
}
