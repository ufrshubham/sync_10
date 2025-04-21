import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';

class RocketComponent extends PositionComponent with CollisionCallbacks {
  RocketComponent({
    required this.input,
    super.position,
    super.anchor,
    super.scale,
  });

  final InputComponent input;
  late final SpriteComponent _rocketSprite;
  late final RectangleHitbox _hitbox;

  var _speed = 0.0;
  final _maxSpeed = 80.0;
  static const _acceleration = 1;

  var _angularSpeed = 0.0;
  final _maxAngularSpeed = 2.0;
  static const _angularAcceleration = 1;

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
    _speed = lerpDouble(_speed, input.vAxis * _maxSpeed, _acceleration * dt)!;
    _angularSpeed =
        lerpDouble(
          _angularSpeed,
          input.hAxis * _maxAngularSpeed,
          _angularAcceleration * dt,
        )!;

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
}
