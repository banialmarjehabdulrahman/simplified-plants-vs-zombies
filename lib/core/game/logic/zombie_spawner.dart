import 'dart:math';

import 'package:flame/components.dart';

import '../../../game/pvz_game.dart';
import '../../../domain/models/zombie_type.dart';
import '../config/game_layout.dart';

/// Handles spawning zombies into the world, given a reference to [PvzGame].
///
/// WaveController will call:
/// - [spawnRegularBatch] every 10 seconds
/// - [spawnBigWave] every 30 seconds
///
/// This now uses [ZombiePool] so we reuse Zombie instances.
class ZombieSpawner {
  ZombieSpawner({required this.game}) : _random = Random();

  final PvzGame game;
  final Random _random;

  int get _laneCount => game.tiles.length;

  void spawnRegularBatch(int count) {
    if (count <= 0) return;

    // ignore: avoid_print
    print('ZombieSpawner: spawning regular batch of $count zombie(s).');

    for (var i = 0; i < count; i++) {
      _spawnOneRandomZombie();
    }
  }

  void spawnBigWave(int count) {
    if (count <= 0) return;

    // ignore: avoid_print
    print('ZombieSpawner: spawning BIG WAVE of $count zombie(s).');

    for (var i = 0; i < count; i++) {
      _spawnOneRandomZombie();
    }
  }

  void _spawnOneRandomZombie() {
    if (_laneCount <= 0) {
      // ignore: avoid_print
      print(
        'ZombieSpawner: no lanes available (tiles list is empty). '
        'Skipping spawn.',
      );
      return;
    }

    final laneIndex = _random.nextInt(_laneCount);

    final randomTypeIndex = _random.nextInt(ZombieType.values.length);
    final type = ZombieType.values[randomTypeIndex];

    final laneTileRow = game.tiles[laneIndex];
    if (laneTileRow.isEmpty) {
      // ignore: avoid_print
      print('ZombieSpawner: lane $laneIndex has no tiles. Skipping spawn.');
      return;
    }

    // Use camera to spawn just off the right of the visible area.
    final visibleRect = game.camera.visibleWorldRect;
    const extraTiles = 6.0;
    final spawnX = visibleRect.right + GameLayout.tileSize * extraTiles;

    final sampleTile = laneTileRow[0];
    final spawnY = sampleTile.position.y + GameLayout.tileSize / 2;

    final spawnPos = Vector2(spawnX, spawnY);

    game.zombiePool.spawnZombie(
      type: type,
      laneIndex: laneIndex,
      spawnPosition: spawnPos,
    );
  }
}
