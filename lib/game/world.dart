import 'dart:async';

import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/hyperspace_streaks_component.dart';
import 'package:flame_game_jam_2025/game/hyperspace_tunnel_component.dart';
import 'package:flame_game_jam_2025/game/input_component.dart';
import 'package:flame_game_jam_2025/game/rocket_component.dart';

class TheSpaceRaceWorld extends World with HasGameReference<TheSpaceRaceGame> {
  final _inputComponent = InputComponent();

  @override
  Future<void> onLoad() async {
    // // ignore: literal_only_boolean_expressions, dead_code
    // if (false) {
    //   final hyperspaceStreaks = HpyerspaceStreaksComponent(
    //     size: Vector2(game.size.x, game.size.y),
    //   );
    //   await add(hyperspaceStreaks);
    //   // ignore: dead_code
    // } else {
    //   final hyperspaceTunnel = HpyerspaceTunnelComponent(
    //     size: Vector2(game.size.x, game.size.y),
    //   );
    //   await add(hyperspaceTunnel);
    // }

    await add(_inputComponent);

    await add(
      RocketComponent(
        position: game.size / 2,
        input: _inputComponent,
        anchor: Anchor.center,
        scale: Vector2.all(0.25),
      ),
    );
  }
}
