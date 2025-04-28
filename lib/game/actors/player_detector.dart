import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class PlayerDetector extends PositionComponent {
  PlayerDetector({this.onPlayerEntered, this.onPlayerExited});

  ValueChanged<PositionComponent>? onPlayerEntered;
  ValueChanged<PositionComponent>? onPlayerExited;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox(radius: 200, anchor: Anchor.center, isSolid: true));
  }
}
