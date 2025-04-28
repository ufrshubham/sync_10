import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sync_10/game/actors/planet_component.dart';
import 'package:sync_10/game/actors/spaceship_component.dart';
import 'package:sync_10/game/level.dart';
import 'package:sync_10/routes/game_play.dart';

class SpacemanComponent extends PositionComponent
    with CollisionCallbacks, ParentIsA<Level>, HasAncestor<Gameplay> {
  SpacemanComponent({
    super.position,
    super.anchor,
    super.children,
    super.nativeAngle,
    super.angle,
    Vector2? scale,
  }) : _scale = scale ?? Vector2.all(1.0);

  late final SpriteComponent _spacemanSprite;

  var _speed = 0.0;
  var _angularSpeed = 0.0;
  var _isInitialShieldActive = true;

  final _moveDirection = Vector2(0, 0);
  final Vector2 _scale;

  static const _maxSpeed = 50.0;
  static const _acceleration = 1.0;
  static const _maxAngularSpeed = 1.5;
  static const _angularAcceleration = 0.8;
  static const _initialShieldTime = 1.0;

  late final double _hitboxRadius;
  late final CircleHitbox _hitbox;

  @override
  Future<void> onLoad() async {
    _spacemanSprite = SpriteComponent(
      sprite: await Sprite.load('Sync10Player.png'),
      anchor: Anchor.center,
      scale: _scale,
    );
    await add(_spacemanSprite);

    _hitboxRadius = _spacemanSprite.size.x * 0.5 * _scale.x;
    await add(
      _hitbox = CircleHitbox(radius: _hitboxRadius, anchor: Anchor.center),
    );

    await add(
      TimerComponent(
        period: _initialShieldTime,
        removeOnFinish: true,
        onTick: () => _isInitialShieldActive = false,
      ),
    );
  }

  @override
  void update(double dt) {
    _handleVInput(dt);
    _handleHInput(dt);
    _updatePosition(dt);
  }

  void _handleVInput(double dt) {
    _speed =
        lerpDouble(
          _speed,
          ancestor.input.vAxis * _maxSpeed,
          _acceleration * dt,
        )!;
  }

  void _handleHInput(double dt) {
    _angularSpeed =
        lerpDouble(
          _angularSpeed,
          ancestor.input.hAxis * _maxAngularSpeed,
          _angularAcceleration * dt,
        )!;
  }

  void _updatePosition(double dt) {
    _spacemanSprite.angle += _angularSpeed * dt;

    _moveDirection.setValues(
      -sin(_spacemanSprite.angle),
      cos(_spacemanSprite.angle),
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
    if (_isInitialShieldActive) {
      if (other is PlanetComponent) {
        other.removeFromParent();
      }
    }
    if (other is SpaceshipComponent) {
      _hitbox.collisionType = CollisionType.inactive;

      add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.3),
          onComplete: removeFromParent,
        ),
      );
    }
  }
}
