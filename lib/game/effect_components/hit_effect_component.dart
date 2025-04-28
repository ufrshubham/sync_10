import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class HitEffectComponent extends PositionComponent {
  HitEffectComponent({
    required super.position,
    required super.angle,
    super.scale,
  });
  @override
  Future<void> onLoad() async {
    final hitSprite = SpriteComponent(
      sprite: await Sprite.load('HitEffect-1.png'),
      anchor: Anchor.topCenter,
      scale: Vector2.zero(),
      children: [
        ScaleEffect.to(
          Vector2.all(1),
          EffectController(
            duration: 0.1,
            curve: Curves.easeInOut,
            repeatCount: 2,
          ),
        ),
        OpacityEffect.to(
          0,
          EffectController(duration: 0.5, curve: Curves.easeOut),
          onComplete: removeFromParent,
        ),
      ],
    );
    await add(hitSprite);
  }
}
