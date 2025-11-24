import '../../../domain/models/plant_type.dart';
import '../../../game/pvz_game.dart';

/// Simple sun bank: how much sun the player currently has.
class SunBank {
  SunBank({this.current = 150});

  int current;

  bool canAfford(int cost) => current >= cost;

  /// Increase the amount of sun in the bank.
  void add(int amount) {
    current += amount;
  }

  void spend(int cost) {
    current -= cost;
    if (current < 0) {
      current = 0;
    }
  }
}

/// Extension on PvzGame that adds behaviour for plant selection & sun state.
/// NOTE: the actual fields (sunBank, selectedPlantType) live on PvzGame itself.
extension PlantStateExt on PvzGame {
  void initPlantState() {
    sunBank = SunBank(current: 150);
    selectedPlantType = null;
  }

  /// Called when the player clicks a plant card.
  /// For now we only select; we’ll spend sun on placement later.
  void selectPlant(PlantDefinition def) {
    selectedPlantType = def.type;
    // ignore: avoid_print
    print('Selected plant: ${def.name}');
  }

  bool isPlantSelected(PlantType type) => selectedPlantType == type;
}
