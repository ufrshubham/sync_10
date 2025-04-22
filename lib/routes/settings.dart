import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/routes/main_menu.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  static const id = 'Settings';
  final TheSpaceRaceGame game;

  const Settings({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: game.backgroundMusic,
                builder:
                    (context, value, child) => SwitchListTile(
                      title: const Text('Music'),
                      value: value,
                      onChanged:
                          (newValue) => game.backgroundMusic.value = newValue,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: game.soundEffects,
                builder:
                    (context, value, child) => SwitchListTile(
                      title: const Text('Sound effects'),
                      value: value,
                      onChanged:
                          (newValue) => game.soundEffects.value = newValue,
                    ),
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
