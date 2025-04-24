import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/game_play.dart';
// import 'package:flame_game_jam_2025/game/hyperspace_streaks_component.dart';
// import 'package:flame_game_jam_2025/game/hyperspace_tunnel_component.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';
import 'package:flame_game_jam_2025/game/planet_component.dart';
import 'package:flame_game_jam_2025/game/rocket_component.dart';
import 'package:flame_game_jam_2025/game/star_nest_component.dart';

class Level extends PositionComponent
    with
        HasTimeScale,
        HasAncestor<Gameplay>,
        HasGameReference<TheSpaceRaceGame> {
  Level(
    this.fileName,
    this.tileSize, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  final String fileName;
  final Vector2 tileSize;

  final _inputComponent = InputComponent();
  final _gamepadComponent = GamepadComponenet();
  late final PositionComponent _rocket;

  @override
  Future<void> onLoad() async {
    // // ignore: literal_only_boolean_expressions, dead_code
    // if (true) {
    //   final hyperspaceStreaks = HpyerspaceStreaksComponent(
    //     size: Gameplay.visibleGameSize,
    //   );
    //   add(hyperspaceStreaks);
    //   // ignore: dead_code
    // } else {
    //   final hyperspaceTunnel = HpyerspaceTunnelComponent(
    //     size: Gameplay.visibleGameSize,
    //   );
    //   add(hyperspaceTunnel);
    // }

    final starNest = StarNextComponent(size: Gameplay.visibleGameSize);
    await add(starNest);

    await add(_inputComponent);
    await add(_gamepadComponent);

    _rocket = RocketComponent(
      position: game.size / 2,
      input: _gamepadComponent,
      anchor: Anchor.center,
      scale: Vector2.all(0.20),
    );

    await add(_rocket);

    await add(
      PlanetComponent(
        position: Vector2(270, 200),
        anchor: Anchor.center,
        scale: Vector2.all(0.75),
      ),
    );

    await add(
      PlanetComponent(
        position: Vector2(800, 500),
        anchor: Anchor.center,
        scale: Vector2.all(0.75),
      ),
    );

    await add(
      PlanetComponent(
        position: Vector2(1000, 200),
        anchor: Anchor.center,
        scale: Vector2.all(0.75),
      ),
    );

    await add(
      PlanetComponent(
        position: Vector2(500, 500),
        anchor: Anchor.center,
        scale: Vector2.all(0.75),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    ancestor.fadeIn();
  }

  void onFinish(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    timeScale = 0.25;
    _inputComponent.isListening = false;

    ancestor.fadeOut().then((_) {
      timeScale = 1;
      ancestor.levelComplete();
    });
  }
}
