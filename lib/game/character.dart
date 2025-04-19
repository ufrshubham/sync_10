import 'dart:async';

import 'package:flame/components.dart';

class Character extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await add(CircleComponent(radius: 10));
  }
}
