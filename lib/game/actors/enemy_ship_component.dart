import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class EnemyShipComponent extends PositionComponent {
  EnemyShipComponent({required this.patrolArea, Vector2? scale, super.position})
    : _scale = scale ?? Vector2(1, 1);

  final double speed = 60.0;
  final Vector2 _scale;
  final Rectangle patrolArea;
  PositionComponent? target;

  late final SpriteComponent _spaceshipSprite;

  var _health = 100.0;
  final _random = Random();
  final _moveDirection = Vector2(0, 0);
  final _randomPosition = Vector2(0, 0);
  var _isPatroling = false;
  MoveEffect? _moveEffect;

  @override
  Future<void> onLoad() async {
    _spaceshipSprite = SpriteComponent(
      anchor: Anchor.center,
      sprite: await Sprite.load('EnemyShip.png'),
      scale: _scale,
      children: [
        MoveEffect.by(
          Vector2(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1)
            ..scale(5)
            ..add(Vector2.all(10)),
          EffectController(
            duration: _random.nextDouble() * 2 + 2,
            curve: Curves.easeInOut,
            infinite: true,
            alternate: true,
          ),
        ),
      ],
    );
    await add(_spaceshipSprite);
    await add(
      PlayerDetector(
        onPlayerEntered: (value) => target = value,
        onPlayerExited: (value) => target = null,
      ),
    );

    await add(
      CircleHitbox(
        radius: _spaceshipSprite.size.x * 0.5 * _scale.x,
        anchor: Anchor.center,
      ),
    );
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (target != null) {
      _moveEffect?.removeFromParent();
      _isPatroling = false;
      final targetPosition = target!.absoluteCenter;
      final relativeVector = targetPosition - absoluteCenter;
      if (relativeVector.length < _spaceshipSprite.size.x * _scale.x + 5) {
        _moveDirection.setZero();
      } else {
        final direction = relativeVector.normalized();
        _moveDirection.setFrom(direction);
      }
      position.add(_moveDirection * speed * dt);
    } else {
      if (!_isPatroling) {
        _isPatroling = true;
        _randomPosition.setFrom(
          Vector2(
            patrolArea.topLeft.x + (_random.nextDouble() * patrolArea.width),
            patrolArea.topLeft.y + (_random.nextDouble() * patrolArea.height),
          ),
        );

        add(
          _moveEffect = MoveEffect.to(
            _randomPosition,
            EffectController(speed: speed),
            onComplete: () => _isPatroling = false,
          ),
        );
      }
    }
  }

  void takeBulletHit(double damage) {
    _health = clampDouble(_health - damage, 0, 100);
    if (_health == 0) {
      removeFromParent();
    }
  }
}

class PlayerDetector extends PositionComponent {
  PlayerDetector({this.onPlayerEntered, this.onPlayerExited});

  ValueChanged<PositionComponent>? onPlayerEntered;
  ValueChanged<PositionComponent>? onPlayerExited;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox(radius: 200, anchor: Anchor.center, isSolid: true));
  }
}
