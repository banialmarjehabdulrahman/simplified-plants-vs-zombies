import '../a_game/pvz_game.dart';
import '../b_components/ui/plant_bar.dart';
import 'game_layout.dart';

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
