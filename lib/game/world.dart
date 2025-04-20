import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_game_jam_2025/game/game.dart';
import 'package:flame_game_jam_2025/game/hyperspace_streaks_component.dart';
import 'package:flame_game_jam_2025/game/hyperspace_tunnel_component.dart';

class TheSpaceRaceWorld extends World with HasGameReference<TheSpaceRaceGame> {
  @override
  Future<void> onLoad() async {
    // ignore: literal_only_boolean_expressions, dead_code
    if (false) {
      final hyperspaceStreaks = HpyerspaceStreaksComponent(
        size: Vector2(game.size.x * 0.5, game.size.y),
      );
      await add(hyperspaceStreaks);
      // ignore: dead_code
    } else {
      final hyperspaceTunnel = HpyerspaceTunnelComponent(
        size: Vector2(game.size.x * 0.5, game.size.y),
      );
      await add(hyperspaceTunnel);
    }

    await add(
      CircleComponent(
        radius: 50,
        anchor: Anchor.center,
        children: [
          MoveEffect.by(
            Vector2(game.size.x * 0.5, game.size.y),
            EffectController(duration: 4, infinite: true, alternate: true),
          ),
        ],
      ),
    );
  }
}
