import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:sync_10/game/planet_component.dart';
import 'package:sync_10/routes/game_play.dart';

class SyncronComponent extends PositionComponent
    with CollisionCallbacks, HasAncestor<Gameplay> {
  SyncronComponent({
    super.position,
    super.size,
    Vector2? scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : _scale = scale ?? Vector2.all(1.0);

  final Vector2 _scale;

  double get syncronValue => 40.0;

  @override
  Future<void> onLoad() async {
    final sprites = [
      await Sprite.load('SyncronLight-1.png'),
      await Sprite.load('SyncronLight-2.png'),
    ];

    final syncronSprite = SpriteComponent(
      sprite: await Sprite.load('Syncron.png'),
      anchor: Anchor.center,
      scale: _scale,
      children: [
        RotateEffect.by(2 * pi, EffectController(duration: 10, infinite: true)),
      ],
    );

    await syncronSprite.add(
      SpriteAnimationComponent(
        anchor: Anchor.center,
        animation: SpriteAnimation.spriteList(sprites, stepTime: 0.2),
        position: syncronSprite.size * 0.5,
      ),
    );

    await add(syncronSprite);
    await add(
      CircleHitbox(
        radius: syncronSprite.size.x * 0.5 * _scale.x * 0.9,
        anchor: Anchor.center,
        isSolid: true,
      ),
    );
  }

  @override
  void renderTree(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      super.renderTree(canvas);
    } else {
      canvas.drawCircle(
        Offset(position.x, position.y),
        40,
        Paint()..color = const Color.fromARGB(255, 111, 0, 255),
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is PlanetComponent) {
      other.removeFromParent();
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}
