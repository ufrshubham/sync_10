import 'package:flame/game.dart';
import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameWidget.controlled(gameFactory: TheSpaceRaceGame.new),
    );
  }
}
