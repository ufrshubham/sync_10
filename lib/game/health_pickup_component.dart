import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class HealthPickupComponent extends PositionComponent {
  HealthPickupComponent({
    super.position,
    super.anchor,
    super.scale,
    super.children,
  });

  double get healthValue => 20.0;

  @override
  Future<void> onLoad() async {
    await add(
      CircleComponent(
        radius: 128 * 0.5,
        anchor: Anchor.center,
        paint: Paint()..color = const Color.fromARGB(255, 89, 0, 253),
      ),
    );
    await add(
      CircleHitbox(
        radius: 128 * 0.5,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
    await add(TimerComponent(period: 10, onTick: removeFromParent));
  }
}
