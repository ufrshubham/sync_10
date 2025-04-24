import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

class InputComponent extends Component with KeyboardHandler {
  double _vAxis = 0;
  bool _up = false;
  bool _down = false;
  double _upInput = 0;
  double _downInput = 0;

  double _hAxis = 0;
  bool _left = false;
  bool _right = false;
  double _leftInput = 0;
  double _rightInput = 0;

  bool _boost = false;

  bool isListening = true;

  double get vAxis => _vAxis;
  double get hAxis => _hAxis;
  bool get boost => _boost;

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

    _boost = isListening && keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }
}

class GamepadComponenet extends InputComponent {
  final _gamepadID1 = '0';
  final _gamepadID2 = '1';

  final _dPad = 'pov';
  final _buttonA = 'button-0';

  final _buttonPressed = 1.0;
  final _buttonReleased = 0.0;

  final _upValue = 0.0;
  final _downValue = 18000.0;
  final _rightValue = 9000.0;
  final _leftValue = 27000.0;
  final _neutralValue = 65535.0;

  @override
  Future<void> onLoad() async {
    Gamepads.eventsByGamepad(_gamepadID1).listen(_onGamepad1Event);
    Gamepads.eventsByGamepad(_gamepadID2).listen(_onGamepad2Event);
  }

  void _onGamepad1Event(GamepadEvent event) {
    if (event.type == KeyType.analog) {
      if (event.key == _dPad) {
        if (event.value == _upValue) {
          _up = true;
          _down = false;
        } else if (event.value == _downValue) {
          _up = false;
          _down = true;
        } else if (event.value == _neutralValue) {
          _up = false;
          _down = false;
        }
      }
    }
  }

  void _onGamepad2Event(GamepadEvent event) {
    if (event.type == KeyType.analog) {
      if (event.key == _dPad) {
        if (event.value == _rightValue) {
          _right = true;
          _left = false;
        } else if (event.value == _leftValue) {
          _right = false;
          _left = true;
        } else if (event.value == _neutralValue) {
          _right = false;
          _left = false;
        }
      }
    }

    if (event.type == KeyType.button) {
      if (event.key == _buttonA) {
        if (event.value == _buttonPressed) {
          _boost = true;
        } else if (event.value == _buttonReleased) {
          _boost = false;
        }
      }
    }
  }
}
