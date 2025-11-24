// lib/f_ui/pause_overlays.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/bloc/game_ui_cubit.dart';

/// Small pause button shown in the bottom-right of the viewport.
///
/// Tapping it toggles the pause state in [GameUiCubit].
class PauseButtonOverlay extends StatelessWidget {
  const PauseButtonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<GameUiCubit, GameUiState>(
          buildWhen: (prev, curr) => prev.isPaused != curr.isPaused,
          builder: (context, state) {
            final isPaused = state.isPaused;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                context.read<GameUiCubit>().togglePaused();
              },
              child: Text(isPaused ? 'Resume' : 'Pause'),
            );
          },
        ),
      ),
    );
  }
}

/// Centered pause menu that appears when the game is paused.
///
/// Lets the player:
/// - See "Game Paused" title
/// - Adjust music volume (slider)
/// - Toggle mute
/// - Resume the game
class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameUiCubit, GameUiState>(
      builder: (context, state) {
        if (!state.isPaused) {
          // When not paused, don't show the overlay at all.
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black54, // semi-transparent dark backdrop
          child: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white70, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Paused',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Music volume slider.
                  Row(
                    children: [
                      const Text(
                        'Music',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: state.musicVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: (state.musicVolume * 100).toStringAsFixed(0),
                          onChanged: (value) {
                            context.read<GameUiCubit>().setMusicVolume(value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Mute toggle.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: state.isMuted,
                        onChanged: (value) {
                          context.read<GameUiCubit>().setMuted(value ?? false);
                        },
                      ),
                      const Text(
                        'Mute music',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Resume button.
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      context.read<GameUiCubit>().setPaused(false);
                    },
                    child: const Text('Resume'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
