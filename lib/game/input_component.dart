import 'dart:io';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:sync_10/game/game.dart';

class InputComponent extends Component with KeyboardHandler {
  InputComponent({Map<LogicalKeyboardKey, VoidCallback>? keyCallbacks})
    : _keyCallbacks = keyCallbacks ?? <LogicalKeyboardKey, VoidCallback>{};

  double _vAxis = 0;
  double _hAxis = 0;

  bool _up = false;
  bool _down = false;
  bool _left = false;
  bool _right = false;
  bool _boost = false;
  bool _slowDown = false;
  bool _fire = false;

  double _upInput = 0;
  double _downInput = 0;
  double _leftInput = 0;
  double _rightInput = 0;

  bool isListening = true;

  double get vAxis => _vAxis;
  double get hAxis => _hAxis;
  bool get boost => _boost;
  bool get slowDown => _slowDown;
  bool get fire => _fire;

  final Map<LogicalKeyboardKey, VoidCallback> _keyCallbacks;

  @override
  void update(double dt) {
    _upInput = _up ? 1 : 0;
    _downInput = _down ? 1 : 0;
    _vAxis = _downInput - _upInput;
    if (_vAxis.abs() < 0.0001) {
      _vAxis = 0;
    }

    _leftInput = _left ? 1 : 0;
    _rightInput = _right ? 1 : 0;
    _hAxis = _rightInput - _leftInput;
    if (_hAxis.abs() < 0.0001) {
      _hAxis = 0;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _up = isListening && keysPressed.contains(LogicalKeyboardKey.arrowUp);
    _down = isListening && keysPressed.contains(LogicalKeyboardKey.arrowDown);

    _left = isListening && keysPressed.contains(LogicalKeyboardKey.keyA);
    _right = isListening && keysPressed.contains(LogicalKeyboardKey.keyD);

    _boost = isListening && keysPressed.contains(LogicalKeyboardKey.keyI);
    _slowDown = isListening && keysPressed.contains(LogicalKeyboardKey.keyO);
    _fire = isListening && keysPressed.contains(LogicalKeyboardKey.space);

    if (isListening && event is KeyDownEvent) {
      for (final entry in _keyCallbacks.entries) {
        if (entry.key == event.logicalKey) {
          entry.value.call();
        }
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }
}

class GamepadComponenet extends InputComponent
    with HasGameReference<Sync10Game> {
  GamepadComponenet({super.keyCallbacks});

  @override
  Future<void> onLoad() async {
    Gamepads.eventsByGamepad(game.player1GamepadId!).listen(_onGamepad1Event);
    Gamepads.eventsByGamepad(game.player2GamepadId!).listen(_onGamepad2Event);
  }

  void _onGamepad1Event(GamepadEvent event) {
    if (event.key == game.player1Mapping['moveUp']?.key) {
      _up = event.value == game.player1Mapping['moveUp']?.keyPressedValue;
    }
    if (event.key == game.player1Mapping['moveDown']?.key) {
      _down = event.value == game.player1Mapping['moveDown']?.keyPressedValue;
    }
    if (event.key == game.player1Mapping['boost']?.key) {
      _boost = event.value == game.player1Mapping['boost']?.keyPressedValue;
    }
    if (event.key == game.player1Mapping['slowDownTime']?.key) {
      _slowDown =
          event.value == game.player1Mapping['slowDownTime']?.keyPressedValue;
    }
  }

  void _onGamepad2Event(GamepadEvent event) {
    if (event.key == game.player2Mapping['turnLeft']?.key) {
      _left = event.value == game.player2Mapping['turnLeft']?.keyPressedValue;
    }
    if (event.key == game.player2Mapping['turnRight']?.key) {
      _right = event.value == game.player2Mapping['turnRight']?.keyPressedValue;
    }
    if (event.key == game.player2Mapping['fire']?.key) {
      _fire = event.value == game.player2Mapping['fire']?.keyPressedValue;
    }
  }
}
