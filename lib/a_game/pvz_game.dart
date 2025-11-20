import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../b_components/tile.dart';
import '../e_core/game_layout.dart';
import '../e_core/grid_logic.dart';

/// Main Flame game for our simplified Plants vs Zombies.
///
/// Uses the new input API via [TapCallbacks] instead of the deprecated
/// [TapDetector] mixin.
class PvzGame extends FlameGame with TapCallbacks {
  PvzGame();

  /// 2D list holding all tiles so we can find them by [row][col].
  late final List<List<Tile>> tiles;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1) Configure camera & world size.
    GameLayout.setupCamera(this);

    // 2) Tell Flame where our images live.
    images.prefix = 'assets/images/';

    // 3) Load grass tiles.
    final lightTileSprite = await loadSprite(
      'green_tiles/tile_light_green.png',
    );
    final darkTileSprite = await loadSprite('green_tiles/tile_dark_green.png');

    // 4) Build the grid (extension method).
    createGrid(lightTileSprite, darkTileSprite);
  }

  /// Delegates tap handling to the grid logic extension.
  @override
  void onTapDown(TapDownEvent event) {
    handleTapDown(event);
  }
}
