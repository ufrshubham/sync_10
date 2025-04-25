import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';
import 'package:flame_game_jam_2025/game/level.dart';
import 'package:flame_game_jam_2025/game/planet_component.dart';

class RocketComponent extends PositionComponent
    with CollisionCallbacks, ParentIsA<Level> {
  RocketComponent({
    required this.input,
    super.position,
    super.anchor,
    super.scale,
    super.children,
  });

  final InputComponent input;
  late final SpriteComponent _rocketSprite;
  late final RectangleHitbox _hitbox;

  var _speed = 0.0;
  static const _maxSpeed = 80.0;
  static const _acceleration = 1;

  static const _maxBoostSpeed = 160.0;
  static const _maxBoostAcceleration = 20.0;

  var _angularSpeed = 0.0;
  static const _maxAngularSpeed = 2.0;
  static const _angularAcceleration = 1;

  static const _maxSlowDownAngularSpeed = 4.0;
  static const _maxSlowDownAngularAcceleration = 2.0;

  final _moveDirection = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    _rocketSprite = SpriteComponent(
      sprite: await Sprite.load('spaceRockets_001.png'),
      anchor: Anchor.center,
    );
    await add(_rocketSprite);

    await add(
      _hitbox = RectangleHitbox(
        size: _rocketSprite.size,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    _updatePosition(dt);
  }

  void _updatePosition(double dt) {
    if (input.boost) {
      _speed =
          lerpDouble(
            _speed,
            input.vAxis * _maxBoostSpeed,
            _maxBoostAcceleration * dt,
          )!;
    } else {
      _speed = lerpDouble(_speed, input.vAxis * _maxSpeed, _acceleration * dt)!;
    }

    if (input.slowDown) {
      parent.timeScale = 0.25;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            input.hAxis * _maxSlowDownAngularSpeed,
            _maxSlowDownAngularAcceleration * dt,
          )!;
    } else {
      parent.timeScale = 1.0;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            input.hAxis * _maxAngularSpeed,
            _angularAcceleration * dt,
          )!;
    }

    _rocketSprite.angle += _angularSpeed * dt;
    _hitbox.angle = _rocketSprite.angle;

    _moveDirection.setValues(
      -sin(_rocketSprite.angle),
      cos(_rocketSprite.angle),
    );

    position.setValues(
      x + _moveDirection.x * _speed * dt,
      y + _moveDirection.y * _speed * dt,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlanetComponent) {}
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is PlanetComponent) {}
  }
}
