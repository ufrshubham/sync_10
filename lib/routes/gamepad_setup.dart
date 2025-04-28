import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:sync_10/game/game.dart';

class GamepadSetup extends StatefulWidget {
  const GamepadSetup({required this.game, super.key, this.onBackPressed});

  static const id = 'GamepadSetup';

  final Sync10Game game;
  final VoidCallback? onBackPressed;

  @override
  State<GamepadSetup> createState() => _GamepadSetupState();
}

class _GamepadSetupState extends State<GamepadSetup> {
  void _detectGamepad(int player) {
    final stream = Gamepads.events;
    stream.take(1).listen((event) {
      setState(() {
        if (player == 1) {
          widget.game.player1GamepadId = event.gamepadId;
          if (widget.game.player1GamepadId == widget.game.player2GamepadId) {
            widget.game.player2GamepadId = null;
          }
        } else if (player == 2) {
          widget.game.player2GamepadId = event.gamepadId;
          if (widget.game.player2GamepadId == widget.game.player1GamepadId) {
            widget.game.player1GamepadId = null;
          }
        }
      });
    }, onDone: stream.drain);
  }

  void _mapAction(int player, String action) {
    final gamepadId =
        player == 1
            ? widget.game.player1GamepadId
            : widget.game.player2GamepadId;
    if (gamepadId == null) {
      return;
    }

    final stream = Gamepads.eventsByGamepad(gamepadId);

    var count = 0;
    stream.take(2).listen((event) {
      setState(() {
        if (player == 1) {
          widget.game.player1Mapping[action]?.action = action;
          widget.game.player1Mapping[action]?.key = event.key;

          if (count == 0) {
            widget.game.player1Mapping[action]?.keyPressedValue = event.value;
          } else if (count == 1) {
            widget.game.player1Mapping[action]?.keyReleasedValue = event.value;
          }
        } else if (player == 2) {
          widget.game.player2Mapping[action]?.action = action;
          widget.game.player2Mapping[action]?.key = event.key;

          if (count == 0) {
            widget.game.player2Mapping[action]?.keyPressedValue = event.value;
          } else if (count == 1) {
            widget.game.player2Mapping[action]?.keyReleasedValue = event.value;
          }
        }
      });
      count++;
    }, onDone: stream.drain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gamepad Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Player 1 Setup', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _detectGamepad(1),
                child: Text(
                  widget.game.player1GamepadId == null
                      ? 'Detect Gamepad for Player 1'
                      : 'Gamepad Detected: ${widget.game.player1GamepadId}',
                ),
              ),
              const SizedBox(height: 10),
              ...widget.game.player1Mapping.keys.map((action) {
                return ListTile(
                  title: Text('Map $action'),
                  subtitle: Text(
                    widget.game.player1Mapping[action]!.key == null
                        ? 'Not Mapped'
                        : '''Mapped to: ${widget.game.player1Mapping[action]?.key}, Pressed Value: ${widget.game.player1Mapping[action]?.keyPressedValue}, Released Value: ${widget.game.player1Mapping[action]?.keyReleasedValue}''',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _mapAction(1, action),
                    child: const Text('Map'),
                  ),
                );
              }),
              const Divider(),
              const Text('Player 2 Setup', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _detectGamepad(2),
                child: Text(
                  widget.game.player2GamepadId == null
                      ? 'Detect Gamepad for Player 2'
                      : 'Gamepad Detected: ${widget.game.player2GamepadId}',
                ),
              ),
              const SizedBox(height: 10),
              ...widget.game.player2Mapping.keys.map((action) {
                return ListTile(
                  title: Text('Map $action'),
                  subtitle: Text(
                    widget.game.player2Mapping[action]!.key == null
                        ? 'Not Mapped'
                        : '''Mapped to: ${widget.game.player2Mapping[action]?.key}, Pressed Value: ${widget.game.player2Mapping[action]?.keyPressedValue}, Released Value: ${widget.game.player2Mapping[action]?.keyReleasedValue}''',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _mapAction(2, action),
                    child: const Text('Map'),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onBackPressed,
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
