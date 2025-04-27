import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sync_10/game/bullet_component.dart';
import 'package:sync_10/game/level.dart';
import 'package:sync_10/game/orb_component.dart';
import 'package:sync_10/game/planet_component.dart';
import 'package:sync_10/routes/game_play.dart';

enum _FlameSprites { flameNormal, flameBoost }

class SpaceshipComponent extends PositionComponent
    with CollisionCallbacks, ParentIsA<Level>, HasAncestor<Gameplay> {
  SpaceshipComponent({
    super.position,
    super.anchor,
    super.scale,
    super.children,
    super.nativeAngle,
    super.angle,
  });

  late final RectangleHitbox _hitbox;
  late final SpriteComponent _spaceShipSprite;

  late final SpriteAnimationGroupComponent<_FlameSprites> _flameLeft;
  late final SpriteAnimationGroupComponent<_FlameSprites> _flameRight;

  var _speed = 0.0;
  var _speedFactor = 0.0;
  var _angularSpeed = 0.0;
  var _nOrbsCollected = 0;
  var _timeSinceLastFire = 0.0;

  final _moveDirection = Vector2(0, 0);

  static const _maxSpeed = 80.0;
  static const _acceleration = 1;
  static const _maxBoostSpeed = 160.0;
  static const _maxBoostAcceleration = 20.0;
  static const _maxAngularSpeed = 2.0;
  static const _angularAcceleration = 1;
  static const _maxSlowDownAngularSpeed = 4.0;
  static const _maxSlowDownAngularAcceleration = 2.0;
  static const _fireDelay = 0.5;

  int get nOrbsCollected => _nOrbsCollected;

  @override
  Future<void> onLoad() async {
    _spaceShipSprite = SpriteComponent(
      scale: Vector2.all(0.75),
      sprite: await Sprite.load('Spaceship.png'),
      anchor: Anchor.center,
    );
    await add(_spaceShipSprite);

    final animation = {
      _FlameSprites.flameNormal: SpriteAnimation.spriteList([
        await Sprite.load('SpaceshipFlamesLow-1.png'),
        await Sprite.load('SpaceshipFlamesLow-2.png'),
      ], stepTime: 0.1),
      _FlameSprites.flameBoost: SpriteAnimation.spriteList([
        await Sprite.load('SpaceshipFlamesHigh-1.png'),
        await Sprite.load('SpaceshipFlamesHigh-2.png'),
      ], stepTime: 0.1),
    };

    _flameLeft = SpriteAnimationGroupComponent<_FlameSprites>(
      anchor: Anchor.topCenter,
      current: _FlameSprites.flameNormal,
      position: Vector2(_spaceShipSprite.width * 0.1, _spaceShipSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    _flameRight = SpriteAnimationGroupComponent<_FlameSprites>(
      anchor: Anchor.topCenter,
      current: _FlameSprites.flameNormal,
      position: Vector2(_spaceShipSprite.width * 0.9, _spaceShipSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    await _spaceShipSprite.add(_flameLeft);
    await _spaceShipSprite.add(_flameRight);

    await add(
      _hitbox = RectangleHitbox(
        size: _spaceShipSprite.size,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    _handleBoost(dt);
    _handleSlowDown(dt);
    _updatePosition(dt);
    _scaleFlames();
    _handleFire(dt);
  }

  @override
  void renderTree(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      super.renderTree(canvas);
    } else {
      canvas.drawCircle(
        Offset(position.x, position.y),
        50,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  void _updatePosition(double dt) {
    _spaceShipSprite.angle += _angularSpeed * dt;
    _hitbox.angle = _spaceShipSprite.angle;

    _moveDirection.setValues(
      -sin(_spaceShipSprite.angle),
      cos(_spaceShipSprite.angle),
    );

    position.setValues(
      x + _moveDirection.x * _speed * dt,
      y + _moveDirection.y * _speed * dt,
    );
  }

  void _scaleFlames() {
    final flameAdjustment = -ancestor.input.hAxis * 0.25;
    _flameLeft.scale.y = _speedFactor - flameAdjustment;
    _flameRight.scale.y = _speedFactor + flameAdjustment;
  }

  void _handleSlowDown(double dt) {
    if (ancestor.input.slowDown) {
      parent.timeScale = 0.25;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            ancestor.input.hAxis * _maxSlowDownAngularSpeed,
            _maxSlowDownAngularAcceleration * dt,
          )!;
    } else {
      parent.timeScale = 1.0;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            ancestor.input.hAxis * _maxAngularSpeed,
            _angularAcceleration * dt,
          )!;
    }
  }

  void _handleBoost(double dt) {
    if (ancestor.input.boost) {
      _flameLeft.current = _FlameSprites.flameBoost;
      _flameRight.current = _FlameSprites.flameBoost;
      _speed =
          lerpDouble(
            _speed,
            ancestor.input.vAxis * _maxBoostSpeed,
            _maxBoostAcceleration * dt,
          )!;

      _speedFactor = -_speed / _maxBoostSpeed;
    } else {
      _flameLeft.current = _FlameSprites.flameNormal;
      _flameRight.current = _FlameSprites.flameNormal;
      _speed =
          lerpDouble(
            _speed,
            ancestor.input.vAxis * _maxSpeed,
            _acceleration * dt,
          )!;

      _speedFactor = -_speed / _maxSpeed;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlanetComponent) {
    } else if (other is OrbComponent) {
      other.removeFromParent();
      _nOrbsCollected++;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is PlanetComponent) {}
  }

  void _handleFire(double dt) {
    _timeSinceLastFire += dt;

    if (ancestor.input.fire && _timeSinceLastFire >= _fireDelay) {
      final bullet = BulletComponent(
        position: position - _moveDirection * (_spaceShipSprite.height / 2),
        direction: -_moveDirection,
      );
      parent.add(bullet);
      _timeSinceLastFire = 0;
    }
  }
}
