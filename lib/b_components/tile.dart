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

  final int gridX;
  final int gridY;

  bool hasPlant = false; // <--- add this if not already there
}
