import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:sync_10/routes/level_selection.dart';
import 'package:sync_10/routes/main_menu.dart';
import 'package:sync_10/routes/settings.dart';

class Sync10Game extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final soundEffects = ValueNotifier(true);
  final backgroundMusic = ValueNotifier(true);

  final router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: {
      MainMenu.id: OverlayRoute(
        (context, game) => MainMenu(game: game as Sync10Game),
      ),
      Settings.id: OverlayRoute(
        (context, game) => Settings(game: game as Sync10Game),
      ),
      LevelSelection.id: OverlayRoute(
        (context, game) => LevelSelection(game: game as Sync10Game),
      ),
      // PauseMenu.id: OverlayRoute(
      //   (context, game) => PauseMenu(game: game as Sync10Game),
      // ),
      // GameOver.id: OverlayRoute(
      //   (context, game) => GameOver(game: game as Sync10Game),
      // ),
      // LevelComplete.id: OverlayRoute(
      //   (context, game) => LevelComplete(game: game as Sync10Game),
      // ),
    },
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 34, 34, 34);

  @override
  Future<void> onLoad() async {
    await add(router);
  }
}
