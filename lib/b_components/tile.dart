import 'package:flame/components.dart';

/// One grid tile (a grass square) in the game board.
class Tile extends SpriteComponent {
  Tile({
    required super.sprite,
    required super.position,
    required super.size,
    required this.gridX,
    required this.gridY,
  });

  /// Column index on the grid.
  final int gridX;

  /// Row index on the grid.
  final int gridY;

  bool hasPlant = false;
}
