import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sync_10/game/actors/asteroid_component.dart';
import 'package:sync_10/game/actors/enemy_ship_component.dart';
import 'package:sync_10/game/actors/planet_component.dart';
import 'package:sync_10/game/actors/spaceship_component.dart';
import 'package:sync_10/game/level.dart';

class BulletComponent extends PositionComponent
    with ParentIsA<Level>, CollisionCallbacks {
  BulletComponent({
    required this.owner,
    required this.damage,
    required super.position,
    required Vector2 direction,
  }) : _direction = direction.clone();

  final double _speed = 300.0;
  final Vector2 _direction;
  final double damage;
  final Component owner;

  @override
  Future<void> onLoad() async {
    size = Vector2(5, 60);

    await add(
      RectangleComponent(
        anchor: Anchor.center,
        size: size,
        angle: _direction.screenAngle(),
        paint:
            Paint()
              ..shader = Gradient.linear(Offset.zero, Offset(0, size.y), [
                const Color.fromARGB(255, 196, 3, 3),
                const Color.fromARGB(0, 255, 0, 0),
              ]),
      ),
    );

    await add(
      RectangleHitbox(
        anchor: Anchor.center,
        size: size,
        angle: _direction.screenAngle(),
      ),
    );
  }

  @override
  void update(double dt) {
    position += _direction.normalized() * _speed * dt;
    if (position.x < 0 || position.x > parent.size.x) {
      removeFromParent();
    } else if (position.y < 0 || position.y > parent.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is AsteroidComponent) {
      other.damage();
      removeFromParent();
    } else if (other is BulletComponent || other is PlanetComponent) {
      removeFromParent();
    } else if (owner is! EnemyShipComponent && other is EnemyShipComponent) {
      other.takeBulletHit(damage);
      removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
