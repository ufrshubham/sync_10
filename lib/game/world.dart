import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_game_jam_2025/game/game.dart';

class TheSpaceRaceWorld extends World with HasGameReference<TheSpaceRaceGame> {
  @override
  Future<void> onLoad() async {
    final fragmentProgram = await FragmentProgram.fromAsset(
      'assets/shaders/hyperspace-streaks.frag',
    );

    final shader = fragmentProgram.fragmentShader();

    final hyperspaceStreaks = HpyerspaceStreaks(
      shader: shader,
      size: Vector2(game.size.x * 0.5, game.size.y),
    );
    await add(hyperspaceStreaks);

    await add(
      CircleComponent(
        radius: 50,
        anchor: Anchor.center,
        children: [
          MoveEffect.by(
            Vector2(game.size.x * 0.5, game.size.y),
            EffectController(duration: 4, infinite: true, alternate: true),
          ),
        ],
      ),
    );
  }
}

class HpyerspaceStreaks extends PositionComponent {
  HpyerspaceStreaks({required this.shader, required super.size});

  final FragmentShader shader;
  final _paint = Paint();

  var _iTime = 0.0;

  @override
  Future<void> onLoad() async {
    shader.setFloat(0, size.x);
    shader.setFloat(1, size.y);
    shader.setFloat(2, _iTime);
    _paint.shader = shader;
  }

  @override
  void update(double dt) {
    _iTime += dt;
    shader.setFloat(2, _iTime);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(x, y, size.x, size.y), _paint);
  }
}
