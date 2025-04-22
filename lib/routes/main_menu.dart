import 'package:flame/game.dart';
import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/game_play.dart';
import 'package:flame_game_jam_2025/routes/settings.dart';
import 'package:flutter/material.dart' hide Route;

class MainMenu extends StatelessWidget {
  static const id = 'MainMenu';
  final TheSpaceRaceGame game;

  const MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('The Space Race', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: () {
                  game.router.pushReplacement(Route(() => Gameplay(0)));
                },
                child: const Text('Play'),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed:
                    () => game.router.pushNamed(Settings.id, replace: true),
                child: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
