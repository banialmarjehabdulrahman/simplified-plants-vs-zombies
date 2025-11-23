import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../b_components/tile.dart';
import '../d_models/plant_type.dart';
import '../e_core/game_layout.dart';
import '../e_core/grid_logic.dart';
import '../e_core/plant_state.dart';
import '../e_core/plant_assets.dart';
import '../e_core/ui_logic.dart';

/// Main Flame game for our simplified Plants vs Zombies.
///
/// Uses the new input API via [TapCallbacks] instead of the deprecated
/// [TapDetector] mixin.
class PvzGame extends FlameGame with TapCallbacks, HasHoverables {
  PvzGame();

  /// 2D list holding all tiles so we can find them by [row][col].
  late final List<List<Tile>> tiles;

  /// How much sun the player has.
  late SunBank sunBank;

  /// Currently selected plant card (if any).
  PlantType? selectedPlantType;

  /// Sprites for each plant type, loaded once at startup.
  late Map<PlantType, Sprite> plantSprites;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1) Camera & world
    GameLayout.setupCamera(this);

    // 2) Asset folders
    images.prefix = 'assets/images/';

    // 3) Load grass tiles
    final lightTileSprite = await loadSprite(
      'green_tiles/tile_light_green.png',
    );
    final darkTileSprite = await loadSprite('green_tiles/tile_dark_green.png');

    // 4) Build grid
    createGrid(lightTileSprite, darkTileSprite);

    // 5) Plant state (sun + selection)
    initPlantState();

    // 6) Plant sprites
    await loadPlantSprites();

    // 7) Bottom plant selection bar
    createPlantBar();
  }

  @override
  void onTapDown(TapDownEvent event) {
    handleTapDown(event);
  }
}

mixin HasHoverables {}
