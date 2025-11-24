import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/game/config/game_layout.dart';
import '../../../domain/components/plant.dart';
import '../../../domain/components/tile.dart';
import '../../../domain/models/plant_type.dart';
import '../../../game/pvz_game.dart';

/// All grid-related logic for [PvzGame] is grouped here as an extension.
/// Keeps PvzGame itself smaller and easier to read.
extension GridLogic on PvzGame {
  /// Creates the lawn grid and stores tiles in [tiles].
  void createGrid(Sprite light, Sprite dark) {
    const startX = 0.0; // start at left edge
    const startY = GameLayout.verticalMargin; // push grid down a bit

    // Initialize the 2D list: one inner list per row.
    tiles = List.generate(GameLayout.rows, (_) => <Tile>[]);

    for (var row = 0; row < GameLayout.rows; row++) {
      for (var col = 0; col < GameLayout.cols; col++) {
        // Alternate between light and dark tiles (checkerboard pattern).
        final isLight = (row + col) % 2 == 0;
        final sprite = isLight ? light : dark;

        // Position of the tile in world coordinates.
        final position = Vector2(
          startX + col * GameLayout.tileSize,
          startY + row * GameLayout.tileSize,
        );

        final tile = Tile(
          sprite: sprite,
          position: position,
          size: Vector2.all(GameLayout.tileSize),
          gridX: col,
          gridY: row,
        );

        tiles[row].add(tile);
        add(tile);
      }
    }
  }

  void handleTapDown(TapDownEvent event) {
    final worldPos = event.localPosition;

    final col = (worldPos.x / GameLayout.tileSize).floor();
    final row = ((worldPos.y - GameLayout.verticalMargin) / GameLayout.tileSize)
        .floor();

    final inX = col >= 0 && col < GameLayout.cols;
    final inY = row >= 0 && row < GameLayout.rows;
    if (!inX || !inY) {
      return;
    }

    final tile = tiles[row][col];

    _highlightTile(tile);
    _placePlantOnTile(tile);

    // ignore: avoid_print
    print('Tapped tile row=$row col=$col');
  }

  /// Small flash effect so we see which tile we clicked.
  void _highlightTile(Tile tile) {
    tile.add(
      SequenceEffect([
        OpacityEffect.to(0.5, EffectController(duration: 0.05)),
        OpacityEffect.to(1.0, EffectController(duration: 0.05)),
      ]),
    );
  }

  void _placePlantOnTile(Tile tile) {
    // 1) Need a selected plant card.
    final type = selectedPlantType;
    if (type == null) {
      AudioManager.instance.playErrorNoSun();
      // ignore: avoid_print
      print('No plant selected.');
      return;
    }

    // 2) Tile must be empty.
    if (tile.hasPlant) {
      AudioManager.instance.playErrorNoSun();
      // ignore: avoid_print
      print('Tile already has a plant.');
      return;
    }

    // 3) Check sun cost.
    final def = PlantDefinition.byType(type);
    if (!sunBank.canAfford(def.cost)) {
      AudioManager.instance.playErrorNoSun();
      // ignore: avoid_print
      print('Not enough sun for ${def.name}. Need ${def.cost}.');
      return;
    }

    // 4) Get sprite for this plant.
    final sprite = plantSprites[type];
    if (sprite == null) {
      // ignore: avoid_print
      print('No sprite loaded for $type');
      return;
    }

    AudioManager.instance.playCardClick();
    // 5) Spend sun and place the plant.
    sunBank.spend(def.cost);

    final plant = Plant(type: type, tile: tile, sprite: sprite);

    tile.hasPlant = true;
    add(plant);

    // Optional: deselect after placing one.
    selectedPlantType = null;
  }
}
