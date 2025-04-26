import 'dart:async';
import 'dart:math';
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
    LevelComplete.id: OverlayRoute(
      (context, game) => LevelComplete(
        onSubmitPressed: _onSubmitPressed,
        onRetryPressed: _restartLevel,
        onExitPressed: _exitToMainMenu,
      ),
    ),
  };

  late final _router = RouterComponent(
    initialRoute: MainMenu.id,
    routes: _routes,
    // routeFactories: _routeFactories,
  );

  @override
  Color backgroundColor() => const Color.fromARGB(255, 34, 34, 34);

  @override
  Future<void> onLoad() async {
    await add(_router);
    client = Supabase.instance.client;
    // client.auth.onAuthStateChange.listen((data) {
    //   switch (data.event) {
    //     case AuthChangeEvent.signedIn:
    //       print('User signed in: ${data.session?.user.id}');
    //       break;
    //     case AuthChangeEvent.signedOut:
    //       print('User signed out: ${data.session?.user.id}');
    //       break;
    //     default:
    //       break;
    //   }
    // });

    // final authResponse = await client.auth.signInAnonymously();

    // if (authResponse.session != null) {
    //   print('User ID: ${authResponse.session?.user.id}');
    //   print('Access Token: ${authResponse.session?.accessToken}');
    //   print('Refresh Token: ${authResponse.session?.refreshToken}');
    //   print('Expires at: ${authResponse.session?.expiresAt}');
    //   print('User email: ${authResponse.session?.user.email}');
    //   print('User phone: ${authResponse.session?.user.phone}');
    //   print('User app_metadata: ${authResponse.session?.user.appMetadata}');
    //   print('User user_metadata: ${authResponse.session?.user.userMetadata}');
    //   print('User created at: ${authResponse.session?.user.createdAt}');
    //   print('User updated at: ${authResponse.session?.user.updatedAt}');
    //   print(
    //     'User email confirmed at: ${authResponse.session?.user.emailConfirmedAt}',
    //   );
    //   print(
    //     'User phone confirmed at: ${authResponse.session?.user.phoneConfirmedAt}',
    //   );
    //   print('User identities: ${authResponse.session?.user.identities}');
    // }
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

  // void _startNextLevel() {
  //   final gameplay = findByKeyName<Gameplay>(Gameplay.id);

  //   if (gameplay != null) {
  //     _startLevel(gameplay.currentLevel + 1);
  //   }
  // }

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

  void _showLevelCompleteMenu(int nStars) {
    _router.pushNamed(LevelComplete.id);
  }

  void _showRetryMenu() {
    _router.pushNamed(RetryMenu.id);
  }

  Future<void> _onSubmitPressed(String value) async {
    final authResponse = await client.auth.signInAnonymously();
    if (authResponse.session != null) {
      final response = await client.from('Leaderboard').insert({
        'DuoName': value,
        'Time': Random().nextInt(1000),
      });

      print('Response: $response');
    }
  }
}
