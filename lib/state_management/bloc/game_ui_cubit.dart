// lib/c_bloc/game_ui_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable UI state for things that are not part of the game world itself,
/// but the surrounding UX (pause, audio settings, etc.).
///
/// This is managed by [GameUiCubit] and observed by Flutter widgets.
@immutable
class GameUiState extends Equatable {
  const GameUiState({
    required this.isPaused,
    required this.musicVolume,
    required this.isMuted,
  });

  /// Whether the game is currently paused from the UI's point of view.
  final bool isPaused;

  /// Background music volume in the range [0.0, 1.0].
  final double musicVolume;

  /// True when music is muted (effective volume should be 0.0).
  final bool isMuted;

  /// Convenience getter: volume that should be applied to AudioManager.
  double get effectiveMusicVolume => isMuted ? 0.0 : musicVolume;

  /// Create a copy with some fields changed.
  GameUiState copyWith({bool? isPaused, double? musicVolume, bool? isMuted}) {
    return GameUiState(
      isPaused: isPaused ?? this.isPaused,
      musicVolume: musicVolume ?? this.musicVolume,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object> get props => [isPaused, musicVolume, isMuted];
}

/// Cubit that manages high-level UI state for the game:
/// - Pause / resume
/// - Music volume & mute
///
/// Flutter widgets will listen to this Cubit (via BlocBuilder/BlocListener)
/// and then call into the Flame game and AudioManager as needed.
class GameUiCubit extends Cubit<GameUiState> {
  GameUiCubit()
    : super(
        const GameUiState(
          isPaused: false,
          musicVolume: 0.4, // should match AudioManager.bgmVolume default
          isMuted: false,
        ),
      );

  /// Set paused flag explicitly.
  void setPaused(bool value) {
    emit(state.copyWith(isPaused: value));
  }

  /// Toggle paused/unpaused.
  void togglePaused() {
    emit(state.copyWith(isPaused: !state.isPaused));
  }

  /// Set music volume; value is clamped to [0.0, 1.0].
  void setMusicVolume(double value) {
    final clamped = value.clamp(0.0, 1.0);
    emit(state.copyWith(musicVolume: clamped));
  }

  /// Set mute flag explicitly.
  void setMuted(bool value) {
    emit(state.copyWith(isMuted: value));
  }

  /// Toggle mute on/off.
  void toggleMuted() {
    emit(state.copyWith(isMuted: !state.isMuted));
  }
}
