import 'dart:ui';

import 'package:flame/components.dart';
import 'package:sync_10/routes/game_play.dart';

class HpyerspaceStreaksComponent extends PositionComponent
    with HasAncestor<Gameplay> {
  HpyerspaceStreaksComponent({required super.size});

  late final FragmentShader _shader;
  final _paint = Paint();

  var _iTime = 0.0;

  @override
  Future<void> onLoad() async {
    final fragmentProgram = await FragmentProgram.fromAsset(
      'assets/shaders/hyperspace-streaks.frag',
    );

    _shader = fragmentProgram.fragmentShader();

    _shader.setFloat(0, size.x);
    _shader.setFloat(1, size.y);
    _shader.setFloat(2, _iTime);
    _paint.shader = _shader;
  }

  @override
  void update(double dt) {
    _iTime += dt;
    _shader.setFloat(2, _iTime);
  }

  @override
  void render(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      canvas.drawRect(Rect.fromLTWH(x, y, size.x, size.y), _paint);
    }
  }
}
