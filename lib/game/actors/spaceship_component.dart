import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sync_10/game/actors/asteroid_component.dart';
import 'package:sync_10/game/actors/bullet_component.dart';
import 'package:sync_10/game/actors/enemy_component.dart';
import 'package:sync_10/game/actors/enemy_ship_component.dart';
import 'package:sync_10/game/actors/planet_component.dart';
import 'package:sync_10/game/actors/player_detector.dart';
import 'package:sync_10/game/hit_effect_component.dart';
import 'package:sync_10/game/level.dart';
import 'package:sync_10/game/pickups/energy_pickup_component.dart';
import 'package:sync_10/game/pickups/fuel_pickup_component.dart';
import 'package:sync_10/game/pickups/health_pickup_component.dart';
import 'package:sync_10/game/pickups/syncron_pickup_component.dart';
import 'package:sync_10/routes/game_play.dart';

enum _FlameSprites { flameNormal, flameBoost }

class SpaceshipComponent extends PositionComponent
    with CollisionCallbacks, ParentIsA<Level>, HasAncestor<Gameplay> {
  SpaceshipComponent({
    super.position,
    super.anchor,
    super.children,
    super.nativeAngle,
    super.angle,
    Vector2? scale,
  }) : _scale = scale ?? Vector2.all(1.0);

  late final SpriteComponent _spaceShipSprite;

  late final SpriteAnimationGroupComponent<_FlameSprites> _flameLeft;
  late final SpriteAnimationGroupComponent<_FlameSprites> _flameRight;

  var _speed = 0.0;
  var _speedFactor = 0.0;
  var _angularSpeed = 0.0;
  var _syncronCollected = 0;
  var _timeSinceLastFire = 0.0;
  var _health = 100.0;
  var _fuel = 100.0;
  var _energy = 100.0;
  var _isGameOver = false;
  var _isInitialShieldActive = true;

  final _moveDirection = Vector2(0, 0);
  final Vector2 _scale;

  static const _maxSpeed = 80.0;
  static const _acceleration = 1;
  static const _maxBoostSpeed = 160.0;
  static const _maxBoostAcceleration = 20.0;
  static const _maxAngularSpeed = 2.0;
  static const _angularAcceleration = 1;
  static const _maxSlowDownAngularSpeed = 4.0;
  static const _maxSlowDownAngularAcceleration = 2.0;
  static const _fireDelay = 0.5;
  static const _fuelConsumption = 1.0;
  static const _fuelConsumptionBoost = 2.0;
  static const _energyConsumptionFire = 1.0;
  static const _energyConsumptionSlowDown = 15;
  static const _initialShieldTime = 1.0;
  static const _bulletDamage = 40.0;
  static const _damageValue = 50.0;

  double get health => _health;

  late final double _hitboxRadius;

  @override
  Future<void> onLoad() async {
    _spaceShipSprite = SpriteComponent(
      sprite: await Sprite.load('Spaceship.png'),
      anchor: Anchor.center,
      scale: _scale,
    );
    await add(_spaceShipSprite);
    await _setupFlames();

    _hitboxRadius = _spaceShipSprite.size.x * 0.5 * _scale.x;
    await add(CircleHitbox(radius: _hitboxRadius, anchor: Anchor.center));

    await add(
      TimerComponent(
        period: _initialShieldTime,
        removeOnFinish: true,
        onTick: () => _isInitialShieldActive = false,
      ),
    );
  }

  @override
  void update(double dt) {
    _handleBoost(dt);
    _handleSlowDown(dt);
    _updatePosition(dt);
    _scaleFlames();
    _handleFire(dt);
    _handleGameOver();
  }

  @override
  void renderTree(Canvas canvas) {
    if (CameraComponent.currentCamera == ancestor.camera) {
      super.renderTree(canvas);
    } else {
      final path = Path();
      const triangleSize = 60.0;

      // Calculate the triangle points
      final tip = Offset(
        position.x - _moveDirection.x * triangleSize,
        position.y - _moveDirection.y * triangleSize,
      );
      final baseLeft = Offset(
        position.x - _moveDirection.y * (triangleSize / 2),
        position.y + _moveDirection.x * (triangleSize / 2),
      );
      final baseRight = Offset(
        position.x + _moveDirection.y * (triangleSize / 2),
        position.y - _moveDirection.x * (triangleSize / 2),
      );

      // Create the triangle path
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(baseLeft.dx, baseLeft.dy);
      path.lineTo(baseRight.dx, baseRight.dy);
      path.close();

      // Draw the triangle
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color.fromARGB(255, 208, 255, 0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0,
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_isInitialShieldActive) {
      return;
    }

    if (other is PlanetComponent ||
        other is AsteroidComponent ||
        other is EnemyShipComponent ||
        other is EnemyComponent) {
      if (intersectionPoints.length == 2) {
        final mid =
            (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = _hitboxRadius - collisionNormal.length;
        collisionNormal.normalize();

        position += collisionNormal.scaled(separationDistance);
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isInitialShieldActive) {
      if (other is PlanetComponent) {
        other.removeFromParent();
      }
      return;
    }

    if (other is PlanetComponent) {
      if (other.isShaking == false) {
        _health = clampDouble(_health - other.damageValue, 0, 100);
        ancestor.updateHealthBar(_health);
        if (intersectionPoints.length == 2) {
          final mid =
              (intersectionPoints.elementAt(0) +
                  intersectionPoints.elementAt(1)) /
              2;
          parent.add(
            HitEffectComponent(
              position: mid,
              scale: Vector2.all(0.5),
              angle: _moveDirection.screenAngle(),
            ),
          );
        }
      }
      other.shake(_moveDirection);
    } else if (other is AsteroidComponent) {
      if (other.isShaking == false) {
        other.damage();
        _health = clampDouble(_health - other.damageValue, 0, 100);
        ancestor.updateHealthBar(_health);
        if (intersectionPoints.length == 2) {
          final mid =
              (intersectionPoints.elementAt(0) +
                  intersectionPoints.elementAt(1)) /
              2;
          parent.add(
            HitEffectComponent(
              position: mid,
              scale: Vector2.all(0.5),
              angle: _moveDirection.screenAngle(),
            ),
          );
        }
      }
      other.shake(_moveDirection);
    } else if (other is EnemyShipComponent) {
      if (other.isShaking == false) {
        other.takeDamage(_damageValue);
        _health = clampDouble(_health - other.damageValue, 0, 100);
        ancestor.updateHealthBar(_health);
        if (intersectionPoints.length == 2) {
          final mid =
              (intersectionPoints.elementAt(0) +
                  intersectionPoints.elementAt(1)) /
              2;
          parent.add(
            HitEffectComponent(
              position: mid,
              scale: Vector2.all(0.5),
              angle: _moveDirection.screenAngle(),
            ),
          );
        }
      }
      other.shake(_moveDirection);
    } else if (other is EnemyComponent) {
      if (other.isShaking == false) {
        other.takeDamage(_damageValue);
        _health = clampDouble(_health - other.damageValue, 0, 100);
        ancestor.updateHealthBar(_health);
        if (intersectionPoints.length == 2) {
          final mid =
              (intersectionPoints.elementAt(0) +
                  intersectionPoints.elementAt(1)) /
              2;
          parent.add(
            HitEffectComponent(
              position: mid,
              scale: Vector2.all(0.5),
              angle: _moveDirection.screenAngle(),
            ),
          );
        }
      }
      other.shake(_moveDirection);
    } else if (other is SyncronPickupComponent) {
      other.removeFromParent();
      _syncronCollected++;
      ancestor.updateSyncronCount(_syncronCollected);

      _health = clampDouble(_health + other.syncronValue, 0, 100);
      ancestor.updateHealthBar(_health, increase: true);

      _fuel = clampDouble(_fuel + other.syncronValue, 0, 100);
      ancestor.updateFuelBar(_fuel, increase: true);

      _energy = clampDouble(_energy + other.syncronValue, 0, 100);
      ancestor.updateEnergyBar(_energy, increase: true);
    } else if (other is HealthPickupComponent) {
      other.removeFromParent();
      _health = clampDouble(_health + other.healthValue, 0, 100);
      ancestor.updateHealthBar(_health, increase: true);
    } else if (other is FuelPickupComponent) {
      other.removeFromParent();
      _fuel = clampDouble(_fuel + other.fuelValue, 0, 100);
      ancestor.updateFuelBar(_fuel, increase: true);
    } else if (other is EnergyPickupComponent) {
      other.removeFromParent();
      _energy = clampDouble(_energy + other.energyValue, 0, 100);
      ancestor.updateEnergyBar(_energy, increase: true);
    } else if (other is PlayerDetector) {
      other.onPlayerEntered?.call(this);
    } else if (other is BulletComponent && other.owner != this) {
      _health = clampDouble(_health - other.damage, 0, 100);
      ancestor.updateHealthBar(_health);
      other.removeFromParent();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is PlayerDetector) {
      other.onPlayerExited?.call(this);
    }
  }

  Future<void> _setupFlames() async {
    final flameSpritesLow = [
      await Sprite.load('SpaceshipFlamesLow-1.png'),
      await Sprite.load('SpaceshipFlamesLow-2.png'),
    ];

    final flameSpritesHigh = [
      await Sprite.load('SpaceshipFlamesHigh-1.png'),
      await Sprite.load('SpaceshipFlamesHigh-2.png'),
    ];

    final animation = {
      _FlameSprites.flameNormal: SpriteAnimation.spriteList(
        flameSpritesLow,
        stepTime: 0.1,
      ),
      _FlameSprites.flameBoost: SpriteAnimation.spriteList(
        flameSpritesHigh,
        stepTime: 0.1,
      ),
    };

    _flameLeft = SpriteAnimationGroupComponent<_FlameSprites>(
      anchor: Anchor.topCenter,
      current: _FlameSprites.flameNormal,
      position: Vector2(_spaceShipSprite.width * 0.1, _spaceShipSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    _flameRight = SpriteAnimationGroupComponent<_FlameSprites>(
      anchor: Anchor.topCenter,
      current: _FlameSprites.flameNormal,
      position: Vector2(_spaceShipSprite.width * 0.9, _spaceShipSprite.height),
      animations: animation,
      scale: Vector2(0.3, 0.25),
    )..opacity = 0.8;

    await _spaceShipSprite.add(_flameLeft);
    await _spaceShipSprite.add(_flameRight);
  }

  void _updatePosition(double dt) {
    _spaceShipSprite.angle += _angularSpeed * dt;

    _moveDirection.setValues(
      -sin(_spaceShipSprite.angle),
      cos(_spaceShipSprite.angle),
    );

    position.setValues(
      x + _moveDirection.x * _speed * dt,
      y + _moveDirection.y * _speed * dt,
    );
  }

  void _scaleFlames() {
    final flameAdjustment = (_fuel > 0 ? -ancestor.input.hAxis : _fuel) * 0.25;
    _flameLeft.scale.y = _speedFactor - flameAdjustment;
    _flameRight.scale.y = _speedFactor + flameAdjustment;
  }

  void _handleSlowDown(double dt) {
    if (ancestor.input.slowDown) {
      parent.timeScale = 0.25;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            (_fuel > 0 ? ancestor.input.hAxis : _fuel) *
                _maxSlowDownAngularSpeed,
            _maxSlowDownAngularAcceleration * dt,
          )!;

      _energy = clampDouble(_energy - _energyConsumptionSlowDown * dt, 0, 100);
      ancestor.updateEnergyBar(_energy);
    } else {
      parent.timeScale = 1.0;
      _angularSpeed =
          lerpDouble(
            _angularSpeed,
            (_fuel > 0 ? ancestor.input.hAxis : _fuel) * _maxAngularSpeed,
            _angularAcceleration * dt,
          )!;
    }
  }

  void _handleBoost(double dt) {
    if (ancestor.input.boost) {
      _flameLeft.current = _FlameSprites.flameBoost;
      _flameRight.current = _FlameSprites.flameBoost;
      _speed =
          lerpDouble(
            _speed,
            ((_fuel > 0) ? ancestor.input.vAxis : _fuel) * _maxBoostSpeed,
            _maxBoostAcceleration * dt,
          )!;

      _speedFactor = -_speed / _maxBoostSpeed;
      _fuel = clampDouble(
        _fuel - _fuelConsumptionBoost * ancestor.input.vAxis.abs() * dt,
        0,
        100,
      );
      ancestor.updateFuelBar(_fuel);
    } else {
      _flameLeft.current = _FlameSprites.flameNormal;
      _flameRight.current = _FlameSprites.flameNormal;
      _speed =
          lerpDouble(
            _speed,
            ((_fuel > 0) ? ancestor.input.vAxis : _fuel) * _maxSpeed,
            _acceleration * dt,
          )!;

      _speedFactor = -_speed / _maxSpeed;
      _fuel = clampDouble(
        _fuel - _fuelConsumption * ancestor.input.vAxis.abs() * dt,
        0,
        100,
      );
      ancestor.updateFuelBar(_fuel);
    }
  }

  void _handleFire(double dt) {
    _timeSinceLastFire += dt;

    if (ancestor.input.fire && _timeSinceLastFire >= _fireDelay) {
      final bullet = BulletComponent(
        owner: this,
        damage: _bulletDamage,
        position: position - _moveDirection * (_spaceShipSprite.height / 2),
        direction: -_moveDirection,
      );
      parent.add(bullet);
      _timeSinceLastFire = 0;
      _energy = clampDouble(_energy - _energyConsumptionFire, 0, 100);
      ancestor.updateEnergyBar(_energy);
    }
  }

  void _handleGameOver() {
    if (_isGameOver == false) {
      if (_fuel == 0) {
        _isGameOver = true;
        ancestor.input.isListening = false;
        ancestor.fadeOut().then((_) => ancestor.onGameOver());
      } else if (_health == 0) {
        _isGameOver = true;
        ancestor.input.isListening = false;
        ancestor.fadeOut().then((_) => ancestor.onGameOver());
      }
    }
  }
}
