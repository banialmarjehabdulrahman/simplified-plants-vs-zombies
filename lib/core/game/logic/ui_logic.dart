import '../../../game/pvz_game.dart';
import '../../../ui/widgets/plant_bar.dart';
import '../config/game_layout.dart';

/// UI-related helpers for PvzGame.
extension UiLogic on PvzGame {
  /// Creates the bottom plant selection bar.
  void createPlantBar() {
    add(
      PlantBar(
        worldWidth: GameLayout.worldWidth,
        worldHeight: GameLayout.worldHeight,
      ),
    );
  }
}
