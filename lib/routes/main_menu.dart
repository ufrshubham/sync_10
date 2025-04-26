import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/game_play.dart';
import 'package:sync_10/routes/settings.dart';

class MainMenu extends StatelessWidget {
  static const id = 'MainMenu';
  final Sync10Game game;

  const MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sync:10',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
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
