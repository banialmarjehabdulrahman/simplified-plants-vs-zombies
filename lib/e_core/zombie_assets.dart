import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../d_models/zombie_type.dart';

/// Loads and provides sprites for all zombie types.
///
/// Similar role to your plant_assets, but for zombies.
/// Call [ZombieAssets.load] once at startup, then keep the
/// instance somewhere accessible (e.g. in PvzGame) and use
/// [spriteFor] when creating zombies.
class ZombieAssets {
  ZombieAssets._(this._sprites);

  final Map<ZombieType, Sprite> _sprites;

  /// Load all zombie sprites from assets.
  ///
  /// Expects files like:
  ///   assets/images/zombies/brute_zombie.png
  ///   assets/images/zombies/crawler_zombie.png
  ///   assets/images/zombies/ghoul_zombie.png
  ///   assets/images/zombies/runner_zombie.png
  ///   assets/images/zombies/stalker_zombie.png
  ///
  /// Make sure these are declared in pubspec.yaml under assets.
  static Future<ZombieAssets> load(Images images) async {
    final Map<ZombieType, Sprite> sprites = {};

    Future<void> loadOne(ZombieDefinition def) async {
      final image = await images.load('zombies/${def.spriteKey}.png');
      sprites[def.type] = Sprite(image);
    }

    for (final def in ZombieCatalog.all) {
      // ignore: avoid_print
      print('Loading zombie sprite: ${def.spriteKey}');
      await loadOne(def);
    }

    return ZombieAssets._(sprites);
  }

  /// Get the sprite for a specific zombie type.
  Sprite spriteFor(ZombieType type) {
    final sprite = _sprites[type];
    if (sprite == null) {
      throw StateError('Sprite for zombie type $type not loaded.');
    }
    return sprite;
  }
}
