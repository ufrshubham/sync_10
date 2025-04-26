import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';

class OrbComponent extends PositionComponent {
  OrbComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  Future<void> onLoad() async {
    await add(
      CircleComponent(
        radius: 20,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF00FF00),
        children: [
          ScaleEffect.by(
            Vector2.all(0.5),
            EffectController(
              duration: 1,
              reverseDuration: 1,
              infinite: true,
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );

    await add(
      CircleHitbox(
        radius: 20,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
  }
}
