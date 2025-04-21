import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class PlanetComponent extends PositionComponent with HasGameReference {
  PlanetComponent({
    required super.position,
    required super.anchor,
    required super.scale,
  });

  static const _planets = [
    'Planet1.png',
    'Planet2.png',
    'Planet3.png',
    'Planet4.png',
  ];

  static final _random = Random();

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await game.images.load(
        PlanetComponent._planets[_random.nextInt(
          PlanetComponent._planets.length,
        )],
      ),
      srcSize: Vector2.all(128),
    );

    final data = spriteSheet.createAnimation(row: 0, stepTime: 0.1);

    final spriteAnimation = SpriteAnimationComponent(
      animation: data,
      anchor: Anchor.center,
    );
    await add(spriteAnimation);

    await add(CircleHitbox(radius: 128 * 0.5, anchor: Anchor.center));
  }
}
