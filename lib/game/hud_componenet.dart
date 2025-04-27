import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Viewport;

class HudComponent extends PositionComponent
    with ParentIsA<Viewport>, HasGameReference {
  late final RectangleComponent _healthBar;
  late final RectangleComponent _healthBarBackground;
  late final SpriteComponent _healthBarIcon;
  bool _isHealthBarEffectRunning = false;

  late final RectangleComponent _energyBar;
  late final RectangleComponent _energyBarBackground;
  late final SpriteComponent _energyBarIcon;
  bool _isEnergyBarEffectRunning = false;

  late final RectangleComponent _fuelBar;
  late final RectangleComponent _fuelBarBackground;
  late final SpriteComponent _fuelBarIcon;
  bool _isFuelBarEffectRunning = false;

  @override
  Future<void> onLoad() async {
    await _setupHealthBar();
    await _setupEnergyBar();
    await _setupFuelBar();
  }

  @override
  void update(double dt) {}

  Future<void> _setupHealthBar() async {
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
      paint: Paint()..color = const Color.fromARGB(255, 225, 69, 69),
      priority: 1,
    );

    _healthBar.add(
      _healthBarIcon = SpriteComponent(
        sprite: await Sprite.load('CollectableHeart.png'),
        anchor: Anchor.center,
        position: Vector2(_healthBar.size.x * 0.5, -10),
        scale: Vector2.all(0.3),
      ),
    );

    await addAll([_healthBar, _healthBarBackground]);
  }

  Future<void> _setupEnergyBar() async {
    _energyBarBackground = RectangleComponent(
      anchor: Anchor.bottomCenter,
      size: Vector2(14, parent.virtualSize.y * 0.25),
      position: Vector2(parent.virtualSize.x - 80, parent.virtualSize.y - 30),
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
    _energyBar = RectangleComponent(
      anchor: _energyBarBackground.anchor,
      size: Vector2(
        _energyBarBackground.size.x - 4,
        _energyBarBackground.size.y,
      ),
      position: _energyBarBackground.position,
      paint: Paint()..color = const Color.fromARGB(255, 253, 155, 40),
      priority: 1,
    );

    _energyBar.add(
      _energyBarIcon = SpriteComponent(
        sprite: await Sprite.load('CollectableEnergy.png'),
        anchor: Anchor.center,
        position: Vector2(_energyBar.size.x * 0.5, -10),
        scale: Vector2.all(0.3),
      ),
    );

    await addAll([_energyBar, _energyBarBackground]);
  }

  Future<void> _setupFuelBar() async {
    _fuelBarBackground = RectangleComponent(
      anchor: Anchor.bottomCenter,
      size: Vector2(14, parent.virtualSize.y * 0.25),
      position: Vector2(parent.virtualSize.x - 130, parent.virtualSize.y - 30),
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
    _fuelBar = RectangleComponent(
      anchor: _fuelBarBackground.anchor,
      size: Vector2(_fuelBarBackground.size.x - 4, _fuelBarBackground.size.y),
      position: _fuelBarBackground.position,
      paint: Paint()..color = const Color.fromARGB(255, 68, 168, 225),
      priority: 1,
    );

    _fuelBar.add(
      _fuelBarIcon = SpriteComponent(
        sprite: await Sprite.load('CollectableFuel.png'),
        anchor: Anchor.center,
        position: Vector2(_fuelBar.size.x * 0.5, -10),
        scale: Vector2.all(0.3),
      ),
    );

    return addAll([_fuelBar, _fuelBarBackground]);
  }

  void updateHealthBar(double health, {bool increase = false}) {
    _healthBar.size.y = _healthBarBackground.size.y * (health / 100);

    if (increase && _isHealthBarEffectRunning == false) {
      _isHealthBarEffectRunning = true;

      _healthBarIcon.add(
        ScaleEffect.by(
          Vector2(2, 1.5),
          EffectController(duration: 0.1, alternate: true, repeatCount: 2),
          onComplete: () => _isHealthBarEffectRunning = false,
        ),
      );
    }
  }

  void updateEnergyBar(double energy, {bool increase = false}) {
    _energyBar.size.y = _energyBarBackground.size.y * (energy / 100);

    if (increase && _isEnergyBarEffectRunning == false) {
      _isEnergyBarEffectRunning = true;

      _energyBarIcon.add(
        ScaleEffect.by(
          Vector2(2, 1.5),
          EffectController(duration: 0.1, alternate: true, repeatCount: 2),
          onComplete: () => _isEnergyBarEffectRunning = false,
        ),
      );
    }
  }

  void updateFuelBar(double fuel, {bool increase = false}) {
    _fuelBar.size.y = _fuelBarBackground.size.y * (fuel / 100);

    if (increase && _isFuelBarEffectRunning == false) {
      _isFuelBarEffectRunning = true;

      _fuelBarIcon.add(
        ScaleEffect.by(
          Vector2(2, 1.5),
          EffectController(duration: 0.1, alternate: true, repeatCount: 2),
          onComplete: () => _isFuelBarEffectRunning = false,
        ),
      );
    }
  }
}
