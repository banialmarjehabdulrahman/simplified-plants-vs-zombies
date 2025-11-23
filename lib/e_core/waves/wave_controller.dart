import 'dart:math';

import 'package:flame/components.dart';

import '../../a_game/pvz_game.dart';

/// Controls the timing of zombie waves and regular spawns.
///
/// - Every [bigWaveInterval] seconds => triggers a "big wave"
/// - Every [regularSpawnInterval] seconds => triggers a "regular spawn"
///
/// It does NOT spawn zombies by itself. Instead, it exposes callbacks:
/// - [onRegularSpawn] with a random count between 1 and 4
/// - [onBigWaveSpawn] with a random count between 5 and 12
/// - [onBigWave] for UI (e.g. the warning popup)
class WaveController extends Component with HasGameRef<PvzGame> {
  WaveController({
    this.bigWaveInterval = 30.0,
    this.regularSpawnInterval = 10.0,
    this.minZombiesPerRegularSpawn = 1,
    this.maxZombiesPerRegularSpawn = 4,
  }) : assert(bigWaveInterval > 0),
       assert(regularSpawnInterval > 0),
       assert(minZombiesPerRegularSpawn > 0),
       assert(maxZombiesPerRegularSpawn >= minZombiesPerRegularSpawn);

  /// Time in seconds between big waves.
  final double bigWaveInterval;

  /// Time in seconds between regular spawns.
  final double regularSpawnInterval;

  /// Min / max zombies to spawn per regular spawn batch.
  final int minZombiesPerRegularSpawn;
  final int maxZombiesPerRegularSpawn;

  /// Countdown timer for the next big wave.
  double _bigWaveTimer = 0;

  /// Countdown timer for the next regular spawn batch.
  double _regularSpawnTimer = 0;

  /// Total time this controller has been running (seconds).
  double _totalTime = 0.0;

  final Random _random = Random();

  /// Expose remaining time so UI can read it later.
  double get timeUntilNextBigWave => _bigWaveTimer;

  /// Optional callback fired whenever a big wave is triggered.
  /// Intended for UI only (e.g. show the "Zombie wave is incoming!" popup).
  void Function()? onBigWave;

  /// Callback fired when a big wave should spawn zombies.
  ///
  /// The [count] parameter will be a random number between 5 and 12 inclusive.
  void Function(int count)? onBigWaveSpawn;

  /// Callback fired when a regular spawn should spawn zombies.
  ///
  /// The [count] parameter will be a random number between
  /// [minZombiesPerRegularSpawn] and [maxZombiesPerRegularSpawn] inclusive.
  void Function(int count)? onRegularSpawn;

  @override
  void onMount() {
    super.onMount();

    // Start both timers from their full intervals.
    _bigWaveTimer = bigWaveInterval;
    _regularSpawnTimer = regularSpawnInterval;

    // ignore: avoid_print
    print(
      'WaveController mounted. Big wave every $bigWaveInterval s, '
      'regular spawn every $regularSpawnInterval s.',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _totalTime += dt;

    // Update big wave timer
    _bigWaveTimer -= dt;
    if (_bigWaveTimer <= 0) {
      _triggerBigWave();
      _bigWaveTimer += bigWaveInterval; // reset for next one
    }

    // Update regular spawn timer
    _regularSpawnTimer -= dt;
    if (_regularSpawnTimer <= 0) {
      _triggerRegularSpawn();
      _regularSpawnTimer += regularSpawnInterval; // reset for next one
    }
  }

  void _triggerBigWave() {
    // 5–12 zombies for big waves
    final count = _random.nextInt(12 - 5 + 1) + 5;

    // ignore: avoid_print
    print(
      'BIG WAVE triggered: $count zombie(s) at controller time = '
      '${_totalTime.toStringAsFixed(2)}s',
    );

    // Notify spawner about how many zombies to create.
    onBigWaveSpawn?.call(count);

    // Notify UI (popup warning, etc.)
    onBigWave?.call();
  }

  void _triggerRegularSpawn() {
    final count =
        _random.nextInt(
          maxZombiesPerRegularSpawn - minZombiesPerRegularSpawn + 1,
        ) +
        minZombiesPerRegularSpawn;

    // ignore: avoid_print
    print(
      'Regular spawn: $count zombie(s) at controller time = '
      '${_totalTime.toStringAsFixed(2)}s',
    );

    onRegularSpawn?.call(count);
  }
}
