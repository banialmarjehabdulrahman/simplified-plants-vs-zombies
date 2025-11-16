import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'a_game/pvz_game.dart';

void main() {
  runApp(const PvzApp());
}

class PvzApp extends StatelessWidget {
  const PvzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = PvzGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: GameWidget(game: game)),
    );
  }
}
