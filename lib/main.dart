// lib/main.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pvz_challenge/state_management/bloc/game_ui_cubit.dart'
    show GameUiCubit, GameUiState;

import 'core/audio/audio_manager.dart';
import 'game/pvz_game.dart';
import 'ui/overlays/pause_overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PvzApp());
}

/// Root widget for the app.
///
/// Provides [GameUiCubit] for BLoC-based state management of
/// pause + audio settings, and shows the [PvzGame] in a [GameWidget].
class PvzApp extends StatelessWidget {
  const PvzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameUiCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PvZ Challenge',
        theme: ThemeData.dark(),
        home: const PvzGamePage(),
      ),
    );
  }
}

/// Hosts the Flame [PvzGame] and overlays a pause button + pause menu
/// controlled by [GameUiCubit].
class PvzGamePage extends StatefulWidget {
  const PvzGamePage({super.key});

  @override
  State<PvzGamePage> createState() => _PvzGamePageState();
}

class _PvzGamePageState extends State<PvzGamePage> {
  late final PvzGame _game;

  @override
  void initState() {
    super.initState();
    _game = PvzGame();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameUiCubit, GameUiState>(
      listenWhen: (previous, current) =>
          previous.isPaused != current.isPaused ||
          previous.effectiveMusicVolume != current.effectiveMusicVolume,
      listener: (context, state) async {
        // 1) Pause/resume the Flame game.
        if (state.isPaused) {
          _game.pauseEngine();
        } else {
          _game.resumeEngine();
        }

        // 2) Apply music volume/mute to the AudioManager.
        await AudioManager.instance.setMusicVolume(state.effectiveMusicVolume);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // The Flame game.
            GameWidget(game: _game),

            // Pause button in the bottom-right corner.
            const PauseButtonOverlay(),

            // Pause menu overlay (only visible when paused).
            const PauseMenuOverlay(),
          ],
        ),
      ),
    );
  }
}
