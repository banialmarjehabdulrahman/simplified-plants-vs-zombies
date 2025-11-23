import 'package:flame/components.dart';

import '../../a_game/pvz_game.dart';
import '../../b_components/plant.dart';
import '../../d_models/plant_type.dart';
import '../ui/sun_popup.dart';

/// System that handles sun production for Sunflower plants.
///
/// - Keeps Plant clean (no sun logic inside Plant).
/// - Each Sunflower gets its own timer.
/// - Every 10s: +150 sun and a floating "+150" popup.
class SunProduction extends Component with HasGameRef<PvzGame> {
  SunProduction();

  /// Per-plant timers.
  ///
  /// Key: Plant instance
  /// Value: accumulated time since last sun production
  final Map<Plant, double> _timers = {};

  static const double _interval = 10.0; // seconds per sun tick
  static const int _sunAmount = 150;

  @override
  void update(double dt) {
    super.update(dt);

    // 1) Remove timers for plants that are gone.
    _timers.removeWhere((plant, _) => !plant.isMounted);

    // 2) Scan all plants in the scene.
    for (final plant in gameRef.children.whereType<Plant>()) {
      if (plant.type != PlantType.sunflower) {
        // Only sunflowers produce sun.
        continue;
      }

      // Ensure a timer exists for this plant.
      _timers[plant] = (_timers[plant] ?? 0) + dt;

      // Timer reached interval => produce sun.
      if (_timers[plant]! >= _interval) {
        _timers[plant] = 0;
        _produceSunFor(plant);
      }
    }
  }

  void _produceSunFor(Plant plant) {
    // Add sun to the bank.
    gameRef.sunBank.current += _sunAmount;

    // Spawn popup slightly above the plant.
    final popupPosition = plant.position + Vector2(0, -10);
    final popup = SunPopup(amount: _sunAmount, worldPosition: popupPosition);
    gameRef.add(popup);

    // Debug.
    // ignore: avoid_print
    print(
      'Sunflower at (${plant.tile.gridX}, ${plant.tile.gridY}) '
      'produced $_sunAmount sun. New total: ${gameRef.sunBank.current}',
    );
  }
}
