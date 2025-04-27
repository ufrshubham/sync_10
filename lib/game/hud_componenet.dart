import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Viewport;

class HudComponent extends PositionComponent
    with ParentIsA<Viewport>, HasGameReference {
  // final _life = TextComponent(
  //   text: 'x3',
  //   anchor: Anchor.centerLeft,
  //   textRenderer: TextPaint(
  //     style: const TextStyle(color: Colors.black, fontSize: 10),
  //   ),
  // );

  // final _score = TextComponent(
  //   text: 'x0',
  //   anchor: Anchor.centerLeft,
  //   textRenderer: TextPaint(
  //     style: const TextStyle(color: Colors.black, fontSize: 10),
  //   ),
  // );

  late final RectangleComponent _healthBar;
  late final RectangleComponent _healthBarBackground;
  bool _isHealthBarEffectRunning = false;

  @override
  Future<void> onLoad() async {
    _healthBarBackground = RectangleComponent(
      anchor: Anchor.bottomCenter,
      size: Vector2(14, parent.virtualSize.y * 0.25),
      position: Vector2(parent.virtualSize.x - 30, parent.virtualSize.y - 30),
      paint:
          Paint()
            ..color = const Color.fromARGB(
              255,
              212,
              154,
              150,
            ).withValues(alpha: 0.5),
      priority: 0,
    );
    _healthBar = RectangleComponent(
      anchor: _healthBarBackground.anchor,
      size: Vector2(
        _healthBarBackground.size.x - 4,
        _healthBarBackground.size.y,
      ),
      position: _healthBarBackground.position,
      paint: Paint()..color = Colors.green,
      priority: 1,
    );

    await addAll([_healthBar, _healthBarBackground]);
  }

  @override
  void update(double dt) {}

  void updateHealthBar(double health) {
    _healthBar.size.y = _healthBarBackground.size.y * (health / 100);

    if (_isHealthBarEffectRunning == false) {
      _isHealthBarEffectRunning = true;

      _healthBarBackground.add(
        ScaleEffect.by(
          Vector2(1.5, 1),
          EffectController(duration: 0.1, alternate: true, repeatCount: 3),
        ),
      );
      _healthBar.add(
        ScaleEffect.by(
          Vector2(1.5, 1),
          EffectController(duration: 0.1, alternate: true, repeatCount: 3),
          onComplete: () => _isHealthBarEffectRunning = false,
        ),
      );
    }
  }
}
