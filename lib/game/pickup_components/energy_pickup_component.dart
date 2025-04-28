import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:sync_10/routes/game_play.dart';

class EnergyPickupComponent extends PositionComponent
    with HasAncestor<Gameplay> {
  EnergyPickupComponent({
    super.position,
    super.anchor,
    Vector2? scale,
    super.children,
  }) : _scale = scale ?? Vector2.all(1.0);

  double get energyValue => 25.0;
  final Vector2 _scale;

  late final CircleHitbox _hitbox;

  @override
  Future<void> onLoad() async {
    final glassSprite = SpriteComponent(
      sprite: await Sprite.load('CollectableGlass.png'),
      anchor: Anchor.center,
      scale: _scale,
    )..opacity = 0.3;
    final energySprite = SpriteComponent(
      sprite: await Sprite.load('CollectableEnergy.png'),
      anchor: Anchor.center,
      scale: _scale * 0.6,
      children: [
        ScaleEffect.to(
          _scale * 0.8,
          EffectController(
            duration: 0.8,
            infinite: true,
            alternate: true,
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );

    await addAll([energySprite, glassSprite]);
    await add(
      _hitbox = CircleHitbox(
        radius: glassSprite.size.x * 0.5 * _scale.x * 0.9,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
    await add(TimerComponent(period: 8, onTick: removeFromParent));
  }

  @override
  void renderTree(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      super.renderTree(canvas);
    } else {
      canvas.drawCircle(
        Offset(position.x, position.y),
        20,
        Paint()..color = const Color.fromARGB(255, 253, 155, 40),
      );
    }
  }

  void onPick() {
    if (_hitbox.collisionType != CollisionType.inactive) {
      _hitbox.collisionType = CollisionType.inactive;
      add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.2, curve: Curves.easeInOut),
          onComplete: removeFromParent,
        ),
      );
    }
  }
}
