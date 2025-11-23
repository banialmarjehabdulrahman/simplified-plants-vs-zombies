import '../a_game/pvz_game.dart';
import '../d_models/plant_type.dart';

/// Loads and stores sprites for each plant type.
extension PlantAssetsExt on PvzGame {
  Future<void> loadPlantSprites() async {
    // Initialize the map that lives on PvzGame.
    plantSprites = {};

    // We assume PlantDefinition has spritePath for each plant.
    for (final def in PlantDefinition.all) {
      final sprite = await loadSprite(def.spritePath);
      plantSprites[def.type] = sprite;
    }
  }
}
