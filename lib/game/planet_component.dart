import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sync_10/routes/game_play.dart';

class PlanetComponent extends PositionComponent
    with HasGameReference, HasAncestor<Gameplay> {
  PlanetComponent({
    required super.position,
    required super.anchor,
    Vector2? scale,
    super.children,
  }) : _scale = scale ?? Vector2.all(1.0);

  static const _planets = [
    'Planet-1.png',
    'Planet-2.png',
    'Planet-3.png',
    'Planet-4.png',
  ];

  static final _random = Random();

  double get damageValue => 10.0;
  final Vector2 _scale;

  @override
  Future<void> onLoad() async {
    final planetSprite = SpriteComponent(
      sprite: await Sprite.load(
        PlanetComponent._planets[_random.nextInt(
          PlanetComponent._planets.length,
        )],
      ),
      scale: _scale,
      anchor: Anchor.center,
    );
    await add(planetSprite);

    await add(
      CircleHitbox(
        radius: planetSprite.size.x * 0.5 * _scale.x * 0.9,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
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
        20,
        Paint()..color = const Color.fromARGB(255, 197, 223, 197),
      );
    }
  }
}
