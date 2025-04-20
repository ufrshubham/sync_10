import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';

class RocketComponent extends SpriteComponent {
  RocketComponent({
    required this.input,
    super.position,
    super.anchor,
    super.scale,
  });

  final InputComponent input;

  var _speed = 0.0;
  final _maxSpeed = 80.0;
  static const _acceleration = 0.5;
  final _moveDirection = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('spaceRockets_001.png');
  }

  @override
  void update(double dt) {
    _updatePosition(dt);
  }

  void _updatePosition(double dt) {
    _moveDirection.x = input.hAxis;
    _moveDirection.y = input.vAxis;

    _moveDirection.normalize();
    // angle = _moveDirection.screenAngle() + pi;

    _speed = lerpDouble(_speed, _maxSpeed, _acceleration * dt)!;
    angle = _moveDirection.screenAngle();

    position.setValues(
      x + _moveDirection.x * _speed * dt,
      y + _moveDirection.y * _speed * dt,
    );
  }
}
