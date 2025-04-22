import 'dart:async';
import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_game_jam_2025/routes/level_selection.dart';
import 'package:flame_game_jam_2025/routes/main_menu.dart';
import 'package:flame_game_jam_2025/routes/settings.dart';
import 'package:flutter/foundation.dart';

class TheSpaceRaceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final soundEffects = ValueNotifier(true);
  final backgroundMusic = ValueNotifier(true);

  final router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: {
      MainMenu.id: OverlayRoute(
        (context, game) => MainMenu(game: game as TheSpaceRaceGame),
      ),
      Settings.id: OverlayRoute(
        (context, game) => Settings(game: game as TheSpaceRaceGame),
      ),
      LevelSelection.id: OverlayRoute(
        (context, game) => LevelSelection(game: game as TheSpaceRaceGame),
      ),
      // PauseMenu.id: OverlayRoute(
      //   (context, game) => PauseMenu(game: game as TheSpaceRaceGame),
      // ),
      // GameOver.id: OverlayRoute(
      //   (context, game) => GameOver(game: game as TheSpaceRaceGame),
      // ),
      // LevelComplete.id: OverlayRoute(
      //   (context, game) => LevelComplete(game: game as TheSpaceRaceGame),
      // ),
    },
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 34, 34, 34);

  @override
  Future<void> onLoad() async {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
    await add(router);
  }
}
