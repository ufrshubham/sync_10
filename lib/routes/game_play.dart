import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/hud_componenet.dart';
import 'package:sync_10/game/input_component.dart';
import 'package:sync_10/game/level.dart';

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
  late final input = GamepadComponenet(
    keyCallbacks: {
      LogicalKeyboardKey.keyP: onPausePressed,
      LogicalKeyboardKey.keyC: () => onLevelCompleted.call(3),
      LogicalKeyboardKey.keyO: onGameOver,
    },
  );

  @override
  Future<void> onLoad() async {
    //bool seeDebug = true;
    final camera = cameras[CameraType.primary]!;
    camera.moveTo(visibleGameSize * 0.5);

    final debugCamera = cameras[CameraType.debug];
    debugCamera?.viewport.position.setFrom(-game.size / 3);

    await addAll([world, camera]);

    final level = Level('level.tmx', Vector2.all(16));
    await world.addAll([level, input]);

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

  void updateHealthBar(double health) {
    _hud.updateHealthBar(health);
  }

  void updateEnergyBar(double energy) {
    _hud.updateEnergyBar(energy);
  }

  void updateFuelBar(double fuel) {
    _hud.updateFuelBar(fuel);
  }
}
