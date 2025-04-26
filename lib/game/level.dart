import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';

import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/game_play.dart';
// import 'package:flame_game_jam_2025/game/hyperspace_streaks_component.dart';
// import 'package:flame_game_jam_2025/game/hyperspace_tunnel_component.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';
import 'package:flame_game_jam_2025/game/orb_component.dart';
import 'package:flame_game_jam_2025/game/planet_component.dart';
import 'package:flame_game_jam_2025/game/rocket_component.dart';
import 'package:flame_game_jam_2025/game/star_nest_component.dart';
import 'package:flame_tiled/flame_tiled.dart';

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

  final _inputComponent = GamepadComponenet();
  late final PositionComponent _rocket;

  static final _random = Random();

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

    await add(_inputComponent);

    final map = await TiledComponent.load(fileName, tileSize);
    size = map.size;

    final starNest = StarNextComponent(size: map.size);
    await add(starNest);

    final spawnAreas = map.tileMap.getLayer<ObjectGroup>('SpawnAreas');
    if (spawnAreas != null) {
      for (final spawnArea in spawnAreas.objects) {
        switch (spawnArea.name) {
          case 'Rocket':
            final randomPosition =
                spawnArea.position..add(
                  Vector2(
                    _random.nextDouble() * spawnArea.size.x,
                    _random.nextDouble() * spawnArea.size.y,
                  ),
                );
            _rocket = RocketComponent(
              position: randomPosition,
              input: _inputComponent,
              anchor: Anchor.center,
              scale: Vector2.all(0.5),
              children: [
                BoundedPositionBehavior(
                  bounds: Rectangle.fromLTWH(16, 16, size.x - 32, size.y - 32),
                ),
              ],
            );
            await add(_rocket);
            break;
          case 'Orb':
            final randomPosition =
                spawnArea.position..add(
                  Vector2(
                    _random.nextDouble() * spawnArea.size.x,
                    _random.nextDouble() * spawnArea.size.y,
                  ),
                );
            await add(
              OrbComponent(position: randomPosition, anchor: Anchor.center),
            );
            break;
        }
      }
    }

    await add(
      PlanetComponent(
        position: Vector2(270, 200),
        anchor: Anchor.center,
        scale: Vector2.all(0.75),
        children: [
          RotateEffect.by(
            2 * pi,
            EffectController(duration: 10, infinite: true),
          ),
        ],
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

    ancestor.camera.follow(_rocket);
    ancestor.camera.setBounds(
      Rectangle.fromLTWH(
        Gameplay.visibleGameSize.x * 0.5,
        Gameplay.visibleGameSize.y * 0.5,
        width - Gameplay.visibleGameSize.x,
        height - Gameplay.visibleGameSize.y,
      ),
    );

    ancestor.miniMap.follow(_rocket);
    ancestor.camera.viewport.add(ancestor.miniMap);
    ancestor.miniMap.viewport.position = Vector2(
      20,
      ancestor.camera.viewport.size.y - ancestor.miniMap.viewport.size.y,
    );
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
