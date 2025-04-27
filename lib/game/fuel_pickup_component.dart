import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class FuelPickupComponent extends PositionComponent {
  FuelPickupComponent({
    super.position,
    super.anchor,
    Vector2? scale,
    super.children,
  }) : _scale = scale ?? Vector2.all(1.0);

  double get fuelValue => 15.0;
  final Vector2 _scale;

  @override
  Future<void> onLoad() async {
    final glassSprite = SpriteComponent(
      sprite: await Sprite.load('CollectableGlass.png'),
      anchor: Anchor.center,
      scale: _scale,
    )..opacity = 0.3;
    final fuelSprite = SpriteComponent(
      sprite: await Sprite.load('CollectableFuel.png'),
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

    await addAll([fuelSprite, glassSprite]);
    await add(
      CircleHitbox(
        radius: glassSprite.size.x * 0.5 * _scale.x * 0.9,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
    await add(TimerComponent(period: 10, onTick: removeFromParent));
  }
}
