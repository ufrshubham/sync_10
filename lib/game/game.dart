import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show KeyEvent;
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_10/routes/credits.dart';
import 'package:sync_10/routes/game_play.dart';
import 'package:sync_10/routes/gamepad_setup.dart';
import 'package:sync_10/routes/leaderboard.dart';
import 'package:sync_10/routes/level_complete.dart';
import 'package:sync_10/routes/main_menu.dart';
import 'package:sync_10/routes/pause_menu.dart';
import 'package:sync_10/routes/retry_menu.dart';
import 'package:sync_10/routes/settings.dart';

class ActionKeyMap {
  String? action;
  String? key;

  double? keyPressedValue;
  double? keyReleasedValue;
}

class Sync10Game extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final Map<String, ActionKeyMap> player1Mapping = {
    'moveUp': ActionKeyMap(),
    'moveDown': ActionKeyMap(),
    'boost': ActionKeyMap(),
    'slowDownTime': ActionKeyMap(),
  };

  final Map<String, ActionKeyMap> player2Mapping = {
    'turnLeft': ActionKeyMap(),
    'turnRight': ActionKeyMap(),
    'fire': ActionKeyMap(),
  };

  String? player1GamepadId;
  String? player2GamepadId;

  static const bgm = 'bgm.mp3';
  static const destroySfx = 'destroy.wav';
  static const fireSfx = 'fire.wav';
  static const hurtSfx = 'hurt.wav';
  static const pickupSfx = 'pickup.wav';
  static const syncronSfx = 'syncron.wav';
  static const gameoverSfx = 'gameover.wav';

  final sfxValueNotifier = ValueNotifier(true);
  final musicValueNotifier = ValueNotifier(true);

  late final SupabaseClient client;

  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute(
      (context, game) => MainMenu(
        onPlayPressed: () => _startLevel(0),
        onSettingsPressed: () => _routeById(Settings.id),
        onLeaderboardPressed: () => _routeById(Leaderboard.id),
        onCreditsPressed: () => _routeById(Credits.id),
      ),
    ),
    Settings.id: OverlayRoute(
      (context, game) => Settings(
        musicValueListenable: musicValueNotifier,
        sfxValueListenable: sfxValueNotifier,
        onMusicValueChanged: (value) => musicValueNotifier.value = value,
        onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        gamepadSetupPressed: () => _routeById(GamepadSetup.id),
        onBackPressed: _popRoute,
      ),
    ),
    Credits.id: OverlayRoute(
      (context, game) => Credits(onBackPressed: _popRoute),
    ),
    PauseMenu.id: OverlayRoute(
      (context, game) => PauseMenu(
        onResumePressed: _resumeGame,
        onRestartPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
    GamepadSetup.id: OverlayRoute(
      (context, game) =>
          GamepadSetup(game: game as Sync10Game, onBackPressed: _popRoute),
    ),
    Leaderboard.id: OverlayRoute(
      (context, game) => Leaderboard(onBackPressed: _popRoute),
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
    RetryMenu.id:
        (argument) => OverlayRoute(
          (context, game) => RetryMenu(
            reason: argument,
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

    FlameAudio.audioCache.loadAll([
      bgm,
      destroySfx,
      fireSfx,
      hurtSfx,
      pickupSfx,
      syncronSfx,
      gameoverSfx,
    ]);
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
    // pauseEngine();
    _router.pushNamed('${LevelComplete.id}/$levelTime');
  }

  void _showRetryMenu(String reason) {
    if (sfxValueNotifier.value) {
      FlameAudio.play(Sync10Game.gameoverSfx);
    }
    pauseEngine();
    _router.pushNamed('${RetryMenu.id}/$reason');
  }

  Future<bool> _onSubmitPressed(String duoName, int time) async {
    final authResponse = await client.auth.signInAnonymously();
    if (authResponse.session != null) {
      final result =
          await client.from('Leaderboard').insert({
            'DuoName': duoName,
            'Time': time,
          }).select();

      if (result.isNotEmpty) {
        final data = result.first;
        final addedDuoName = data['DuoName'] as String?;

        if (addedDuoName != null) {
          return true;
        }
      }
    }
    return false;
  }
}
