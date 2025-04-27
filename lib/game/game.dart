import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show KeyEvent;
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_10/routes/game_play.dart';
import 'package:sync_10/routes/level_complete.dart';
import 'package:sync_10/routes/main_menu.dart';
import 'package:sync_10/routes/pause_menu.dart';
import 'package:sync_10/routes/retry_menu.dart';
import 'package:sync_10/routes/settings.dart';

class Sync10Game extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final sfxValueNotifier = ValueNotifier(true);
  final musicValueNotifier = ValueNotifier(true);

  late final SupabaseClient client;

  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute(
      (context, game) => MainMenu(
        onPlayPressed: () => _startLevel(0),
        onSettingsPressed: () => _routeById(Settings.id),
      ),
    ),
    Settings.id: OverlayRoute(
      (context, game) => Settings(
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        onBackPressed: _popRoute,
      ),
    ),
    PauseMenu.id: OverlayRoute(
      (context, game) => PauseMenu(
        onResumePressed: _resumeGame,
        onRestartPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
    RetryMenu.id: OverlayRoute(
      (context, game) => RetryMenu(
        onRetryPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
  };

  late final _routeFactories = <String, Route Function(String)>{
    LevelComplete.id:
        (argument) => OverlayRoute(
          (context, game) => LevelComplete(
            levelTime: int.parse(argument),
            onSubmitPressed: _onSubmitPressed,
            onRetryPressed: _restartLevel,
            onExitPressed: _exitToMainMenu,
          ),
        ),
  };

  late final _router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: _routes,
    routeFactories: _routeFactories,
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 34, 34, 34);

  @override
  Future<void> onLoad() async {
    await add(_router);
    client = Supabase.instance.client;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (event is KeyDownEvent) {
        if (paused) {
          resumeEngine();
          _router.pop();
        } else {
          pauseEngine();
          _router.pushNamed(PauseMenu.id);
        }
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void _popRoute() {
    _router.pop();
  }

  void _startLevel(int levelIndex) {
    // _router.pop();
    _router.pushReplacement(
      Route(
        () => Gameplay(
          levelIndex,
          onPausePressed: _pauseGame,
          onLevelCompleted: _showLevelCompleteMenu,
          onGameOver: _showRetryMenu,
          key: ComponentKey.named(Gameplay.id),
        ),
      ),
      name: Gameplay.id,
    );
  }

  void _restartLevel() {
    final gameplay = findByKeyName<Gameplay>(Gameplay.id);

    if (gameplay != null) {
      _router.pop();
      _startLevel(gameplay.currentLevel);
      resumeEngine();
    }
  }

  void _pauseGame() {
    _router.pushNamed(PauseMenu.id);
    pauseEngine();
  }

  void _resumeGame() {
    _router.pop();
    resumeEngine();
  }

  void _exitToMainMenu() {
    _resumeGame();
    _router.pushReplacementNamed(MainMenu.id);
  }

  void _showLevelCompleteMenu(int levelTime) {
    pauseEngine();
    _router.pushNamed('${LevelComplete.id}/$levelTime');
  }

  void _showRetryMenu() {
    _router.pushNamed(RetryMenu.id);
  }

  Future<void> _onSubmitPressed(String duoName, int time) async {
    final authResponse = await client.auth.signInAnonymously();
    if (authResponse.session != null) {
      await client.from('Leaderboard').insert({
        'DuoName': duoName,
        'Time': time,
      });
    }
  }
}
