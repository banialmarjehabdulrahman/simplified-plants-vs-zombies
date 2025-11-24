import 'package:flame/components.dart';

import '../../core/audio/audio_manager.dart';
import '../../core/ui/hud/sun_popup.dart';
import '../../game/pvz_game.dart';
import '../components/plant.dart';
import '../models/plant_type.dart';

/// System that handles sun production for Sunflower plants.
///
/// - Keeps Plant clean (no sun logic inside Plant).
/// - Each Sunflower gets its own timer.
/// - Every 10s: +150 sun and a floating "+150" popup.
class SunProduction extends Component with HasGameRef<PvzGame> {
  SunProduction();

  /// Per-plant timers.
  final Map<Plant, double> _timers = {};

  static const double _interval = 10.0;
  static const int _sunAmount = 150;

  @override
  void update(double dt) {
    super.update(dt);

    final plants = gameRef.children.whereType<Plant>();

    for (final plant in plants) {
      if (plant.type != PlantType.sunflower) {
        continue;
      }

      final currentTimer = _timers[plant] ?? 0;
      final newTimer = currentTimer + dt;

      if (newTimer >= _interval) {
        _produceSun(plant);
        _timers[plant] = 0;
      } else {
        _timers[plant] = newTimer;
      }
    }

    // Clean up timers for plants that got removed.
    _timers.removeWhere((plant, _) => !plant.isMounted || plant.isDead);
  }

  void _produceSun(Plant plant) {
    // Actually add sun to the player's bank.
    gameRef.sunBank.add(_sunAmount);

    // Spawn popup slightly above the plant.
    final popupPosition = plant.position + Vector2(0, -10);
    final popup = SunPopup(amount: _sunAmount, worldPosition: popupPosition);
    gameRef.add(popup);

    // SFX: sunflower produces sun.
    AudioManager.instance.playPlantProduceSun();

    // Debug.
    // ignore: avoid_print
    print(
      'Sunflower at (${plant.tile.gridX}, ${plant.tile.gridY}) '
      'produced $_sunAmount sun. New total: ${gameRef.sunBank.current}',
    );
  }
}
