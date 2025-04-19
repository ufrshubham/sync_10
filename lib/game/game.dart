import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_game_jam_2025/game/world.dart';
import 'package:flame_tiled/flame_tiled.dart';

class TheSpaceRaceGame extends FlameGame<TheSpaceRaceWorld> {
  TheSpaceRaceGame() : super(world: TheSpaceRaceWorld());

  var _cameraP1 = CameraComponent();
  var _cameraP2 = CameraComponent();

  // @override
  // Color backgroundColor() => const Color.fromARGB(255, 238, 248, 254);

  @override
  Future<void> onLoad() async {
    camera.removeFromParent();

    print('onLoad $size');

    _cameraP1 = CameraComponent(
      viewport: FixedSizeViewport(size.x * 0.5, size.y)
        ..position = Vector2(0, 0),
      world: world,
    );
    _cameraP2 = CameraComponent(
      viewport: FixedSizeViewport(size.x * 0.5, size.y)
        ..position = Vector2(size.x * 0.5, 0),
      world: world,
    );

    _cameraP1.moveTo(Vector2(size.x * 0.25, size.y * 0.5));
    _cameraP2.moveTo(Vector2(size.x * 0.25, size.y * 0.5));

    add(_cameraP1);
    add(_cameraP2);

    _cameraP1.viewport.size = Vector2(size.x * 0.5, size.y);
    _cameraP2.viewport.size = Vector2(size.x * 0.5, size.y);

    _cameraP2.viewport.position = Vector2(size.x * 0.5, 0);

    world.add(
      CircleComponent(
        radius: 50,
        anchor: Anchor.center,
        children: [
          MoveEffect.by(
            Vector2(size.x * 0.5, size.y),
            EffectController(duration: 4, infinite: true, alternate: true),
          ),
        ],
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    print('onGameResize $size');

    _cameraP1.viewport = FixedSizeViewport(size.x * 0.5, size.y);
    _cameraP2.viewport = FixedSizeViewport(size.x * 0.5, size.y);

    _cameraP2.viewport.position = Vector2(size.x * 0.5, 0);
  }
}
