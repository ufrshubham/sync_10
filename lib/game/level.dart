import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:sync_10/game/actors/asteroid_component.dart';
import 'package:sync_10/game/actors/enemy_component.dart';
import 'package:sync_10/game/actors/enemy_ship_component.dart';
import 'package:sync_10/game/actors/planet_component.dart';
import 'package:sync_10/game/actors/spaceship_component.dart';
import 'package:sync_10/game/effect_components/blast_effect_component.dart';
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/pickup_components/energy_pickup_component.dart';
import 'package:sync_10/game/pickup_components/fuel_pickup_component.dart';
import 'package:sync_10/game/pickup_components/health_pickup_component.dart';
import 'package:sync_10/game/pickup_components/syncron_pickup_component.dart';
import 'package:sync_10/game/shader_components/star_nest_component.dart';
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
  double _elapsedTime = 0;

  var _syncronsToCollect = 0;
  int get syncronsToCollect => _syncronsToCollect;

  int get levelTime => _elapsedTime.toInt();

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

    await game.images.load('Radar.png');

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
          case 'Syncron':
            final randomPosition =
                spawnArea.position..add(
                  Vector2(
                    _random.nextDouble() * spawnArea.size.x,
                    _random.nextDouble() * spawnArea.size.y,
                  ),
                );
            await add(
              SyncronPickupComponent(
                position: randomPosition,
                anchor: Anchor.center,
                scale: Vector2.all(0.3),
              ),
            );
            _syncronsToCollect++;
            break;

          case 'Planet':
            for (var i = 0; i < 40; ++i) {
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
            final healthSpawner = SpawnComponent.periodRange(
              minPeriod: 15,
              maxPeriod: 25,
              factory: (amount) {
                return HealthPickupComponent(
                  anchor: Anchor.center,
                  scale: Vector2.all(0.4),
                );
              },
              area: Rectangle.fromLTWH(
                spawnArea.position.x,
                spawnArea.position.y,
                spawnArea.size.x,
                spawnArea.size.y,
              ),
            );

            await add(healthSpawner);
            break;

          case 'FuelPickup':
            final fuelSpawner = SpawnComponent.periodRange(
              minPeriod: 15,
              maxPeriod: 25,
              factory: (amount) {
                return FuelPickupComponent(
                  anchor: Anchor.center,
                  scale: Vector2.all(0.4),
                );
              },
              area: Rectangle.fromLTWH(
                spawnArea.position.x,
                spawnArea.position.y,
                spawnArea.size.x,
                spawnArea.size.y,
              ),
            );

            await add(fuelSpawner);
            break;

          case 'EnergyPickup':
            final energySpawner = SpawnComponent.periodRange(
              minPeriod: 15,
              maxPeriod: 25,
              factory: (amount) {
                return EnergyPickupComponent(
                  anchor: Anchor.center,
                  scale: Vector2.all(0.4),
                );
              },
              area: Rectangle.fromLTWH(
                spawnArea.position.x,
                spawnArea.position.y,
                spawnArea.size.x,
                spawnArea.size.y,
              ),
            );

            await add(energySpawner);
            break;

          case 'Asteroid':
            final asteroidSpawner = SpawnComponent.periodRange(
              minPeriod: 15,
              maxPeriod: 30,
              selfPositioning: true,
              factory: (amount) {
                final randomPosition =
                    spawnArea.position..add(
                      Vector2(
                        _random.nextDouble() * spawnArea.size.x,
                        _random.nextDouble() * spawnArea.size.y,
                      ),
                    );
                return AsteroidComponent(
                  position: randomPosition,
                  moveDirection: (size * 0.5 - randomPosition).normalized(),
                  anchor: Anchor.center,
                  scale: Vector2.all(0.4),
                );
              },
            );

            await add(asteroidSpawner);
            break;

          case 'Enemy':
            for (var i = 0; i < 3; ++i) {
              final randomPosition =
                  spawnArea.position..add(
                    Vector2(
                      _random.nextDouble() * spawnArea.size.x,
                      _random.nextDouble() * spawnArea.size.y,
                    ),
                  );
              final enemy = EnemyShipComponent(
                patrolArea: Rectangle.fromLTWH(
                  spawnArea.position.x,
                  spawnArea.position.y,
                  spawnArea.size.x,
                  spawnArea.size.y,
                ),
                position: randomPosition,
                scale: Vector2.all(0.5),
              );
              await add(enemy);
            }

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

    ancestor.miniMap.backdrop.add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache('Radar.png')),
        size: ancestor.miniMap.viewport.virtualSize,
      )..opacity = 0.6,
    );

    ancestor.updateSyncronToCollect(_syncronsToCollect);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (ancestor.isLevelCompleted == false) {
      _elapsedTime += dt;
      ancestor.updateTimeElapsed(_elapsedTime);
    }
  }

  Future<void> onLevelCompleted() {
    ancestor.camera.moveTo(size * 0.5);
    final effect = FunctionEffect(
      (target, progress) {
        ancestor.camera.viewfinder.zoom = clampDouble(1 - progress, 0.4, 1);
      },
      EffectController(duration: 0.5),
      onComplete: () {
        propagateToChildren<SpawnComponent>((spawner) {
          spawner.removeFromParent();
          return true;
        });
        propagateToChildren<EnemyShipComponent>((enemy) {
          enemy.removeFromParent();
          add(BlastEffectComponent(position: enemy.position));
          return true;
        });
        propagateToChildren<EnemyComponent>((enemy) {
          enemy.removeFromParent();
          add(BlastEffectComponent(position: enemy.position));
          return true;
        });
        propagateToChildren<AsteroidComponent>((asteroid) {
          asteroid.removeFromParent();
          add(BlastEffectComponent(position: asteroid.position));
          return true;
        });
        propagateToChildren<PlanetComponent>((planet) {
          planet.removeFromParent();
          add(BlastEffectComponent(position: planet.position));
          return true;
        });
        propagateToChildren<HealthPickupComponent>((health) {
          health.removeFromParent();
          return true;
        });
        propagateToChildren<FuelPickupComponent>((fuel) {
          fuel.removeFromParent();
          return true;
        });
        propagateToChildren<EnergyPickupComponent>((energy) {
          energy.removeFromParent();
          return true;
        });
        propagateToChildren<SyncronPickupComponent>((syncron) {
          syncron.removeFromParent();
          return true;
        });

        // propagateToChildren<StarNextComponent>((star) {
        //   star.removeFromParent();
        //   return true;
        // });
      },
    );
    add(effect);

    return effect.completed;
  }
}
