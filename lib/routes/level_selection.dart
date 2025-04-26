import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/game_play.dart';
import 'package:sync_10/routes/main_menu.dart';

class LevelSelection extends StatelessWidget {
  static const id = 'LevelSelection';
  final Sync10Game game;

  const LevelSelection({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Level Selection', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 50,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              shrinkWrap: true,
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 200),
              itemBuilder:
                  (context, index) => OutlinedButton(
                    onPressed: () {
                      game.router.pushReplacement(
                        Route(() => Gameplay(index + 1)),
                      );
                    },
                    child: Text('Level ${index + 1}'),
                  ),
            ),
            const SizedBox(height: 2),
            IconButton(
              onPressed:
                  () => game.router.pushNamed(MainMenu.id, replace: true),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
