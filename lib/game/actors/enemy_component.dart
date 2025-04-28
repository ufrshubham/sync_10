import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:sync_10/game/actors/bullet_component.dart';
import 'package:sync_10/game/actors/player_detector.dart';
import 'package:sync_10/game/effect_components/blast_effect_component.dart';
import 'package:sync_10/game/game.dart';
import 'package:sync_10/game/level.dart';

class EnemyComponent extends PositionComponent
    with ParentIsA<Level>, HasGameReference<Sync10Game> {
  EnemyComponent({required this.patrolArea, Vector2? scale, super.position})
    : _scale = scale ?? Vector2.all(1);

  final double speed = 40.0;
  final Vector2 _scale;
  final Rectangle patrolArea;
  PositionComponent? target;

  late final SpriteAnimationComponent _enemySprite;

  var _health = 30.0;
  final _random = Random();
  final _moveDirection = Vector2(0, 0);
  final _randomPosition = Vector2(0, 0);
  var _isPatroling = false;
  MoveEffect? _moveEffect;

  double get damageValue => 10;
  var _isShaking = false;
  bool get isShaking => _isShaking;

  var _timeSinceLastFire = 0.0;

  static const _fireDelay = 2;
  static const _bulletDamage = 5.0;

  @override
  Future<void> onLoad() async {
    scale = Vector2.zero();
    await add(ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.25)));

    final sprites = [
      await Sprite.load('EnemyRed-1.png'),
      await Sprite.load('EnemyRed-2.png'),
    ];

    _enemySprite = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(sprites, stepTime: 0.2),
      anchor: Anchor.center,
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
    await add(_enemySprite);
    await add(
      PlayerDetector(
        onPlayerEntered: (value) => target = value,
        onPlayerExited: (value) => target = null,
      ),
    );

    await add(
      CircleHitbox(
        radius: _enemySprite.size.x * 0.8 * _scale.x,
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
      final direction = relativeVector.normalized();

      if (relativeVector.length < _enemySprite.size.x * _scale.x + 5) {
        _moveDirection.setZero();
      } else {
        _moveDirection.setFrom(direction);
      }
      position.add(_moveDirection * speed * dt);

      _timeSinceLastFire += dt;
      if (_timeSinceLastFire > _fireDelay) {
        _timeSinceLastFire = 0;

        final bullet = BulletComponent(
          owner: this,
          position: absolutePosition + direction * _enemySprite.size.x * 0.4,
          direction: direction,
          damage: _bulletDamage,
        );
        parent.add(bullet);
        if (game.sfxValueNotifier.value) {
          FlameAudio.play(Sync10Game.fireSfx);
        }
      }
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
    _health = clampDouble(_health - damage, 0, 30);
    if (_health == 0) {
      parent.add(
        BlastEffectComponent(position: position, scale: Vector2.all(0.4)),
      );
      if (game.sfxValueNotifier.value) {
        FlameAudio.play(Sync10Game.destroySfx);
      }

      add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.25),
          onComplete: removeFromParent,
        ),
      );
    }
  }

  void shake(Vector2 moveDirection) {
    if (_isShaking == false) {
      _isShaking = true;
      _enemySprite.add(
        MoveEffect.by(
          moveDirection.normalized() * 5,
          EffectController(duration: 0.06, alternate: true, repeatCount: 3),
          onComplete: () => _isShaking = false,
        ),
      );
    }
  }

  void takeDamage(double damage) {
    _health = clampDouble(_health - damage, 0, 30);
    if (_health == 0) {
      parent.add(
        BlastEffectComponent(position: position, scale: Vector2.all(0.4)),
      );
      if (game.sfxValueNotifier.value) {
        FlameAudio.play(Sync10Game.destroySfx);
      }

      add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.25),
          onComplete: removeFromParent,
        ),
      );
    }
  }
}
