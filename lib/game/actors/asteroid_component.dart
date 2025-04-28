import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:sync_10/game/effect_components/blast_effect_component.dart';
import 'package:sync_10/game/level.dart';
import 'package:sync_10/routes/game_play.dart';

class AsteroidComponent extends PositionComponent
    with ParentIsA<Level>, HasAncestor<Gameplay> {
  AsteroidComponent({
    required this.moveDirection,
    super.position,
    super.anchor,
    Vector2? scale,
  }) : _scale = scale ?? Vector2.all(1.0);

  final Vector2 _scale;
  final Vector2 moveDirection;
  late final SpriteGroupComponent<_AsteroidDamage> _asteroid;
  static const _speed = 50.0;

  double get damageValue => 10;
  var _isShaking = false;
  bool get isShaking => _isShaking;

  @override
  Future<void> onLoad() async {
    _asteroid = SpriteGroupComponent<_AsteroidDamage>(
      current: _AsteroidDamage.normal,
      scale: _scale,
      anchor: Anchor.center,
      sprites: {
        _AsteroidDamage.normal: await Sprite.load('AsteroidNormal.png'),
        _AsteroidDamage.damaged: await Sprite.load('AsteroidDamaged.png'),
      },
      children: [
        RotateEffect.by(2 * pi, EffectController(duration: 10, infinite: true)),
      ],
    );
    await add(_asteroid);

    await add(
      CircleHitbox(
        radius: _asteroid.size.x * 0.5 * _scale.x,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    position.add(moveDirection * _speed * dt);
    if (position.x < 0 || position.x > parent.size.x) {
      removeFromParent();
    } else if (position.y < 0 || position.y > parent.size.y) {
      removeFromParent();
    }
  }

  @override
  void renderTree(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      super.renderTree(canvas);
    } else {
      final paint =
          Paint()
            ..color = const Color.fromARGB(255, 75, 46, 0)
            ..style = PaintingStyle.fill;

      final path = Path();
      final radius = _asteroid.size.x * 0.7 * _scale.x;
      final centerX = position.x;
      final centerY = position.y;

      for (var i = 0; i < 6; i++) {
        final angle = (2 * pi / 6) * i - pi / 2;
        final x = centerX + radius * cos(angle);
        final y = centerY + radius * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  void damage() {
    if (_asteroid.current == _AsteroidDamage.normal) {
      _asteroid.current = _AsteroidDamage.damaged;
    } else {
      parent.add(
        BlastEffectComponent(position: position, scale: Vector2.all(0.4)),
      );
      removeFromParent();
    }
  }

  void shake(Vector2 moveDirection) {
    if (_isShaking == false) {
      _isShaking = true;
      _asteroid.add(
        MoveEffect.by(
          moveDirection.normalized() * 5,
          EffectController(duration: 0.06, alternate: true, repeatCount: 3),
          onComplete: () => _isShaking = false,
        ),
      );
    }
  }
}

enum _AsteroidDamage { normal, damaged }
