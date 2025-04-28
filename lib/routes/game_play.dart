import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/hud_componenet.dart';
import 'package:sync_10/game/input_component.dart';
import 'package:sync_10/game/level.dart';
import 'package:sync_10/game/shader_components/hyperspace_streaks_component.dart';

enum CameraType { primary, miniMap, debug }

class Gameplay extends Component with HasGameReference<Sync10Game> {
  Gameplay(
    this.currentLevel, {
    required this.onPausePressed,
    required this.onLevelCompleted,
    required this.onGameOver,
    super.key,
  });

  static final visibleGameSize = Vector2(1280, 720);
  static const id = 'Gameplay';

  final int currentLevel;
  final world = World();
  RectangleComponent? _fadeComponent;

  final VoidCallback onPausePressed;
  final ValueChanged<int> onLevelCompleted;
  final VoidCallback onGameOver;

  late final Level _level;
  bool isLevelCompleted = false;
  var _isSwitchingLevels = false;
  var _levelTime = 0;

  late final cameras = <CameraType, CameraComponent>{
    CameraType.primary: CameraComponent.withFixedResolution(
      width: visibleGameSize.x,
      height: visibleGameSize.y,
      world: world,
    ),
    CameraType.miniMap: CameraComponent(
      viewport: CircularViewport(Gameplay.visibleGameSize.x * 0.07)
        ..priority = 10,
      viewfinder:
          Viewfinder()
            ..zoom = 0.125
            ..priority = 10,
      world: world,
      backdrop: RectangleComponent(
        size: Gameplay.visibleGameSize,
        paint:
            Paint()
              ..color = const Color.fromARGB(
                124,
                12,
                27,
                16,
              ).withValues(alpha: 0.5),
      ),
    )..priority = 10,
    CameraType.debug: CameraComponent.withFixedResolution(
      width: visibleGameSize.x * 15,
      height: visibleGameSize.y * 15,
      world: world,
    ),
  };

  CameraComponent get camera => cameras[CameraType.primary]!;
  CameraComponent get miniMap => cameras[CameraType.miniMap]!;
  CameraComponent? get debugCamera => cameras[CameraType.debug];

  late final HudComponent _hud;
  late final input =
      kIsWeb
          ? InputComponent(
            keyCallbacks: {
              LogicalKeyboardKey.keyP: onPausePressed,
              LogicalKeyboardKey.keyC: () => updateSyncronCount(8),
              LogicalKeyboardKey.keyG: onGameOver,
            },
          )
          : GamepadComponenet(
            keyCallbacks: {
              LogicalKeyboardKey.keyP: onPausePressed,
              LogicalKeyboardKey.keyC: () => updateSyncronCount(8),
              LogicalKeyboardKey.keyG: onGameOver,
            },
          );

  AudioPlayer? _bgmPlayer;
  static const _bgmFadeRate = 1;
  static const _bgmMinVol = 0;
  static const _bgmMaxVol = 0.6;

  @override
  Future<void> onLoad() async {
    if (game.musicValueNotifier.value) {
      _bgmPlayer = await FlameAudio.loopLongAudio(Sync10Game.bgm, volume: 0);
    }

    //bool seeDebug = true;
    final camera = cameras[CameraType.primary]!;
    camera.moveTo(visibleGameSize * 0.5);

    final debugCamera = cameras[CameraType.debug];
    debugCamera?.viewport.position.setFrom(-game.size / 3);

    await addAll([world, camera]);

    _level = Level('level.tmx', Vector2.all(16));
    await world.addAll([_level, input]);

    _hud = HudComponent();

    await camera.viewport.addAll([
      _fadeComponent = RectangleComponent(
        size: visibleGameSize,
        paint: Paint()..color = game.backgroundColor(),
      ),
      _hud,
    ]);

    // ignore: dead_code
    // if (seeDebug) {
    //   await add(debugCamera!);
    // }
  }

  Future<void> fadeIn() async {
    final effect = OpacityEffect.fadeOut(LinearEffectController(1));
    _fadeComponent?.add(effect);
    await effect.completed;
  }

  Future<void> fadeOut() async {
    final effect = OpacityEffect.fadeIn(LinearEffectController(1));
    _fadeComponent?.add(effect);
    await effect.completed;
  }

  void levelComplete() {
    // game.router.pushNamed(GameOver.id, replace: true);
  }

  void updateHealthBar(double health, {bool increase = false}) {
    _hud.updateHealthBar(health, increase: increase);
  }

  void updateEnergyBar(double energy, {bool increase = false}) {
    _hud.updateEnergyBar(energy, increase: increase);
  }

  void updateFuelBar(double fuel, {bool increase = false}) {
    _hud.updateFuelBar(fuel, increase: increase);
  }

  void updateTimeElapsed(double timeElapsed) {
    _hud.updateTimeElapsed(timeElapsed);
  }

  Future<void> updateSyncronCount(int syncronCollected) async {
    _hud.updateSyncronCount(syncronCollected);

    if (_level.syncronsToCollect == syncronCollected) {
      // _level.timeScale = 0;
      _levelTime = _level.levelTime;
      input.isListening = false;
      await _level.onLevelCompleted();
      isLevelCompleted = true;
    }
  }

  void updateSyncronToCollect(int syncronToCollect) {
    _hud.updateSyncronToCollect(syncronToCollect);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_bgmPlayer != null) {
      if (isLevelCompleted) {
        if (_bgmPlayer!.volume > _bgmMinVol) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, _bgmMinVol, _bgmFadeRate * dt)!,
          );
        }
      } else {
        if (_bgmPlayer!.volume < _bgmMaxVol) {
          _bgmPlayer!.setVolume(
            lerpDouble(_bgmPlayer!.volume, _bgmMaxVol, _bgmFadeRate * dt)!,
          );
        }
      }
    }

    if (isLevelCompleted) {
      if (_isSwitchingLevels == false) {
        _isSwitchingLevels = true;
        fadeOut().then((_) {
          _level.removeFromParent();
          camera.viewfinder.zoom = 1.0;
          camera.viewport.remove(_hud);
          miniMap.removeFromParent();

          fadeIn().then((_) {
            final hyperspaceStreaks = HpyerspaceStreaksComponent(
              size: _level.size,
              onComplete: () {
                onLevelCompleted.call(_levelTime);
              },
            );
            world.add(hyperspaceStreaks);
          });
        });
      }
    }
  }

  @override
  void onRemove() {
    _bgmPlayer?.dispose();
    super.onRemove();
  }
}
