import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sync_10/game/game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameWidget.controlled(gameFactory: Sync10Game.new),
    );
  }
}
