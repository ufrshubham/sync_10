import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/health_pickup_component.dart';
import 'package:sync_10/game/orb_component.dart';
import 'package:sync_10/game/planet_component.dart';
import 'package:sync_10/game/rocket_component.dart';
import 'package:sync_10/game/star_nest_component.dart';
import 'package:sync_10/routes/game_play.dart';

class Level extends PositionComponent
    with HasTimeScale, HasAncestor<Gameplay>, HasGameReference<Sync10Game> {
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
            _rocket = SpaceshipComponent(
              position: randomPosition,
              anchor: Anchor.center,
              scale: Vector2.all(0.3),
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

          case 'Planet':
            for (var i = 0; i < 50; ++i) {
              final randomPosition =
                  spawnArea.position..add(
                    Vector2(
                      _random.nextDouble() * spawnArea.size.x,
                      _random.nextDouble() * spawnArea.size.y,
                    ),
                  );
              await add(
                PlanetComponent(
                  position: randomPosition,
                  anchor: Anchor.center,
                  scale: Vector2.all(_random.nextDouble() * 0.5 + 0.25),
                  children: [
                    RotateEffect.by(
                      2 * pi,
                      EffectController(
                        duration: _random.nextDouble() * 30 + 20,
                        infinite: true,
                      ),
                    ),
                  ],
                ),
              );
            }
            break;

          case 'HealthPickup':
            final healthSpawner = SpawnComponent(
              period: 15,
              factory: (amount) {
                return HealthPickupComponent(anchor: Anchor.center);
              },
              area: Rectangle.fromLTWH(
                spawnArea.position.x,
                spawnArea.position.y,
                spawnArea.size.x,
                spawnArea.size.y,
              ),
            )..debugMode = true;

            await add(healthSpawner);
            break;
        }
      }
    }
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

      ancestor.camera.viewport.virtualSize.y -
          ancestor.miniMap.viewport.virtualSize.y -
          20,
    );
  }

  void onFinish(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    timeScale = 0.25;
    ancestor.input.isListening = false;

    ancestor.fadeOut().then((_) {
      timeScale = 1;
      ancestor.levelComplete();
    });
  }
}
