import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/level.dart';
import 'package:flutter/material.dart';

enum CameraType { primary, debug }

class Gameplay extends Component with HasGameReference<TheSpaceRaceGame> {
  static final visibleGameSize = Vector2(1280, 720);

  final int currentLevelIndex;
  final world = World();
  RectangleComponent? _fadeComponent;

  late final cameras = <CameraType, CameraComponent>{
    CameraType.primary: CameraComponent.withFixedResolution(
      width: visibleGameSize.x,
      height: visibleGameSize.y,
      world: world,
    ),
    CameraType.debug: CameraComponent.withFixedResolution(
      width: visibleGameSize.x * 15,
      height: visibleGameSize.y * 15,
      world: world,
    ),
  };

  Gameplay(this.currentLevelIndex);

  @override
  Future<void> onLoad() async {
    //bool seeDebug = true;
    final camera = cameras[CameraType.primary]!;
    camera.moveTo(visibleGameSize * 0.5);

    final debugCamera = cameras[CameraType.debug];
    debugCamera?.viewport.position.setFrom(-game.size / 3);

    await addAll([world, camera]);

    final level = Level('Level$currentLevelIndex.tmx', Vector2.all(16));
    await world.add(level);

    await camera.viewport.add(
      _fadeComponent = RectangleComponent(
        size: visibleGameSize,
        paint: Paint()..color = game.backgroundColor(),
      ),
    );

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
}
