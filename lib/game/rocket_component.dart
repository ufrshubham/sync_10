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

class RocketComponent extends PositionComponent
    with CollisionCallbacks, ParentIsA<Level>, HasAncestor<Gameplay> {
  RocketComponent({
    super.position,
    super.anchor,
    super.scale,
    super.children,
    super.nativeAngle,
    super.angle,
  });

  late final SpriteComponent _rocketSprite;
  // late final SpriteGroupComponent<_RocketFlameSprites> _rocketFlameSprite1;
  // late final SpriteGroupComponent<_RocketFlameSprites> _rocketFlameSprite2;
  late final RectangleHitbox _hitbox;

  late final SpriteAnimationGroupComponent<_RocketFlameSprites>
  _rocketFlameLeft;
  late final SpriteAnimationGroupComponent<_RocketFlameSprites>
  _rocketFlameRight;

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
    _rocketSprite = SpriteComponent(
      scale: Vector2.all(0.75),
      sprite: await Sprite.load('Spaceship.png'),
      anchor: Anchor.center,
    );
    await add(_rocketSprite);

    final animation = {
      _RocketFlameSprites.flameNormal: SpriteAnimation.spriteList([
        await Sprite.load('SpaceshipFlamesLow-1.png'),
        await Sprite.load('SpaceshipFlamesLow-2.png'),
      ], stepTime: 0.1),
      _RocketFlameSprites.flameBoost: SpriteAnimation.spriteList([
        await Sprite.load('SpaceshipFlamesHigh-1.png'),
        await Sprite.load('SpaceshipFlamesHigh-2.png'),
      ], stepTime: 0.1),
    };

    _rocketFlameLeft = SpriteAnimationGroupComponent<_RocketFlameSprites>(
      anchor: Anchor.topCenter,
      current: _RocketFlameSprites.flameNormal,
      position: Vector2(_rocketSprite.width * 0.1, _rocketSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    _rocketFlameRight = SpriteAnimationGroupComponent<_RocketFlameSprites>(
      anchor: Anchor.topCenter,
      current: _RocketFlameSprites.flameNormal,
      position: Vector2(_rocketSprite.width * 0.9, _rocketSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    await _rocketSprite.add(_rocketFlameLeft);
    await _rocketSprite.add(_rocketFlameRight);

    await add(
      _hitbox = RectangleHitbox(
        size: _rocketSprite.size,
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

  void _scaleFlames() {
    final flameAdjustment = -ancestor.input.hAxis * 0.25;
    _rocketFlameLeft.scale.y = _speedFactor - flameAdjustment;
    _rocketFlameRight.scale.y = _speedFactor + flameAdjustment;
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
      _rocketFlameLeft.current = _RocketFlameSprites.flameBoost;
      _rocketFlameRight.current = _RocketFlameSprites.flameBoost;
      _speed =
          lerpDouble(
            _speed,
            ancestor.input.vAxis * _maxBoostSpeed,
            _maxBoostAcceleration * dt,
          )!;

      _speedFactor = -_speed / _maxBoostSpeed;
    } else {
      _rocketFlameLeft.current = _RocketFlameSprites.flameNormal;
      _rocketFlameRight.current = _RocketFlameSprites.flameNormal;
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
        position: position - _moveDirection * (_rocketSprite.height / 2),
        direction: -_moveDirection,
      );
      parent.add(bullet);
      _timeSinceLastFire = 0;
    }
  }
}

enum _RocketFlameSprites { flameNormal, flameBoost }
