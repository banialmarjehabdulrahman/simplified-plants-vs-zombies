import 'package:flame/camera.dart';
import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';

/// Central place for board size, tile size, and camera setup.
class GameLayout {
  /// Number of rows (lanes) on the lawn.
  static const int rows = 6;

  /// Number of columns (plant / zombie slots) on the lawn.
  static const int cols = 51;

  /// Size of each tile in world units (matches the PNG size).
  static const double tileSize = 64;

  /// Empty space above and below the grid, in world units.
  static const double verticalMargin = 256;

  /// Logical world width: grid fills the whole width.
  static const double worldWidth = cols * tileSize;

  /// Logical world height: grid + top + bottom margins.
  static const double worldHeight = rows * tileSize + 2 * verticalMargin;

  static Null get gridTop => null;

  /// Configures the camera viewport for our game.
  static void setupCamera(PvzGame game) {
    game.camera.viewport = FixedResolutionViewport(
      resolution: Vector2(worldWidth, worldHeight),
    );
  }
}
