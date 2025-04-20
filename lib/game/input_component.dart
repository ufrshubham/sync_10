import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class InputComponent extends Component with KeyboardHandler {
  double vAxis = 0;
  final _throttleSpeed = 10;
  bool _up = false;
  bool _down = false;
  double _upInput = 0;
  double _downInput = 0;

  double hAxis = 0;
  final _steerSpeed = 2;
  bool _left = false;
  bool _right = false;
  double _leftInput = 0;
  double _rightInput = 0;

  bool isListening = true;

  @override
  void update(double dt) {
    _upInput = lerpDouble(_upInput, _up ? 1 : 0, _throttleSpeed * dt)!;
    _downInput = lerpDouble(_downInput, _down ? 1 : 0, _throttleSpeed * dt)!;

    vAxis = _downInput - _upInput;

    if (vAxis.abs() < 0.0001) {
      vAxis = 0;
    }

    _leftInput = lerpDouble(_leftInput, _left ? 1 : 0, _steerSpeed * dt)!;
    _rightInput = lerpDouble(_rightInput, _right ? 1 : 0, _steerSpeed * dt)!;

    hAxis = _rightInput - _leftInput;

    if (hAxis.abs() < 0.0001) {
      hAxis = 0;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _up = isListening && keysPressed.contains(LogicalKeyboardKey.arrowUp);
    _down = isListening && keysPressed.contains(LogicalKeyboardKey.arrowDown);

    _left = isListening && keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    _right = isListening && keysPressed.contains(LogicalKeyboardKey.arrowRight);
    return super.onKeyEvent(event, keysPressed);
  }
}
