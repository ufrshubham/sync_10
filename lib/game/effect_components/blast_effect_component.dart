import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class BlastEffectComponent extends PositionComponent {
  BlastEffectComponent({required super.position, super.scale});

  static final _random = Random();

  @override
  Future<void> onLoad() async {
    angle = 2 * pi * _random.nextDouble();
    final blastSprite = SpriteComponent(
      sprite: await Sprite.load('BoomEffect.png'),
      anchor: Anchor.center,
      children: [
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
        OpacityEffect.to(
          0,
          EffectController(duration: 0.5, curve: Curves.easeOut),
          onComplete: removeFromParent,
        ),
      ],
    );
    await add(blastSprite);
  }
}
