// lib/e_core/audio/audio_manager.dart
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';

/// Global singleton that manages:
/// - Background music playlist (multiple tracks, loops through them)
/// - Sound effects (SFX) for zombies, plants, UI, game over, etc.
class AudioManager {
  AudioManager._internal();

  /// Singleton instance.
  static final AudioManager instance = AudioManager._internal();

  bool _initialized = false;

  /// Background music playlist (relative to assets/audio/).
  ///
  /// Make sure these files exist:
  ///   assets/audio/music/track1.mp3
  ///   assets/audio/music/track2.mp3
  ///   assets/audio/music/track3.mp3
  final List<String> _bgmTracks = [
    'music/track1.mp3',
    'music/track2.mp3',
    'music/track3.mp3',
  ];

  /// Variants for zombie hurt SFX (we pick one at random).
  final List<String> _zombieHurtVariants = const [
    'sfx/zombie_hurt0.mp3',
    'sfx/zombie_hurt1.mp3',
    'sfx/zombie_hurt2.mp3',
    'sfx/zombie_hurt3.mp3',
  ];

  final Random _random = Random();

  int _currentTrackIndex = 0;
  AudioPlayer? _bgmPlayer;

  /// Volume controls (0.0 – 1.0).
  double bgmVolume = 0.4;
  double sfxVolume = 1.0;

  /// Call once from PvzGame.onLoad() to preload all audio.
  Future<void> init() async {
    if (_initialized) return;

    // Preload music and SFX to avoid first-play stutters.
    await FlameAudio.audioCache.loadAll([..._bgmTracks, ..._allSfxFiles]);

    _initialized = true;
  }

  /// All sound effect file paths we want cached.
  List<String> get _allSfxFiles => [
    // Zombie
    ..._zombieHurtVariants,
    'sfx/zombie_die.mp3',
    'sfx/zombie_reach_house.mp3',

    // Plants
    'sfx/peashooter_shoot.mp3',
    'sfx/sunflower_produce.mp3',

    // UI / game state
    'sfx/card_click.mp3',
    'sfx/error_no_sun.mp3',
    'sfx/game_win.mp3',
    'sfx/game_lose.mp3',
    'sfx/huge_wave.mp3',
    'sfx/zombie_reach_house.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Background music playlist
  // ---------------------------------------------------------------------------

  /// Start background music playlist (if not empty).
  ///
  /// Safe to call multiple times; it will just keep playing.
  Future<void> playBackgroundMusic() async {
    if (_bgmTracks.isEmpty) {
      return;
    }

    _currentTrackIndex %= _bgmTracks.length;
    await _playTrack(_currentTrackIndex);
  }

  /// Skip to the next background track in the playlist (for debugging).
  Future<void> playNextTrack() async {
    if (_bgmTracks.isEmpty) {
      return;
    }

    // Move to next index and wrap around.
    _currentTrackIndex = (_currentTrackIndex + 1) % _bgmTracks.length;

    // Stop current track (if any) and start the next one immediately.
    await stopBackgroundMusic();
    await _playTrack(_currentTrackIndex);
  }

  Future<void> _playTrack(int index) async {
    // Stop any previous track.
    await _bgmPlayer?.stop();

    final file = _bgmTracks[index];

    // Debug: see which track is playing.
    // ignore: avoid_print
    print('AudioManager: playing BGM track #$index -> $file');

    // Use playLongAudio for music-length tracks.
    final player = await FlameAudio.playLongAudio(file, volume: bgmVolume);
    _bgmPlayer = player;

    // When this track finishes, move to the next one (looping playlist).
    player.onPlayerComplete.listen((event) {
      _currentTrackIndex = (_currentTrackIndex + 1) % _bgmTracks.length;
      _playTrack(_currentTrackIndex);
    });
  }

  Future<void> stopBackgroundMusic() async {
    await _bgmPlayer?.stop();
    _bgmPlayer = null;
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgmPlayer?.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await _bgmPlayer?.resume();
  }

  // ---------------------------------------------------------------------------
  // SFX helpers (one method per “game event”)
  // ---------------------------------------------------------------------------

  // --- Zombie SFX ---

  /// Random zombie hurt variant for variety.
  Future<void> playZombieHurt() async {
    if (_zombieHurtVariants.isEmpty) {
      return;
    }

    final index = _random.nextInt(_zombieHurtVariants.length);
    final file = _zombieHurtVariants[index];

    await _playSfx(file);
  }

  Future<void> playZombieDie() => _playSfx('sfx/zombie_die.mp3');

  Future<void> playZombieReachHouse() => _playSfx('sfx/zombie_reach_house.mp3');

  // --- Plant SFX ---

  /// Basic peashooter firing.
  Future<void> playPlantShootPeashooter() =>
      _playSfx('sfx/peashooter_shoot.mp3');

  /// Sunflower producing sun.
  Future<void> playPlantProduceSun() => _playSfx('sfx/sunflower_produce.mp3');

  Future<void> playDamagePlant() => _playSfx('sfx/damage_plant.mp3');

  // --- UI / feedback SFX ---

  /// Card clicked / selected.
  Future<void> playCardClick() => _playSfx('sfx/card_click.mp3');

  /// Error when clicking a card without enough sun.
  Future<void> playErrorNoSun() => _playSfx('sfx/error_no_sun.mp3');

  /// Game won.
  Future<void> playGameWin() => _playSfx('sfx/game_win.mp3');

  /// Game lost.
  Future<void> playGameLose() => _playSfx('sfx/game_lose.mp3');

  /// Big / huge wave incoming.
  Future<void> playHugeWave() => _playSfx('sfx/huge_wave.mp3');

  // --- Internal helper ---

  /// Update background music volume while the game is running.
  ///
  /// [volume] should already be in [0.0, 1.0]. This updates the stored
  /// [bgmVolume] and the currently playing BGM track (if any).
  Future<void> setMusicVolume(double volume) async {
    bgmVolume = volume.clamp(0.0, 1.0);

    // If a track is already playing, update its volume immediately.
    if (_bgmPlayer != null) {
      await _bgmPlayer!.setVolume(bgmVolume);
    }
  }

  Future<void> _playSfx(String file) async {
    await FlameAudio.play(file, volume: sfxVolume);
  }
}
