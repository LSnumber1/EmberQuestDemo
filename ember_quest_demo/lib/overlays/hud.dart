import 'dart:async';

import 'package:ember_quest_demo/ember_quest.dart';
import 'package:ember_quest_demo/overlays/heart.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hub extends PositionComponent with HasGameRef<EmberQuestGame> {
  Hub(
      {super.position,
      super.size,
      super.scale,
      super.angle,
      super.anchor,
      super.children,
      super.priority = 5});

  late TextComponent _scoreTextComponent;

  @override
  FutureOr<void> onLoad() async {
    _scoreTextComponent = TextComponent(
        text: '${game.starsCollected}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color.fromRGBO(10, 10, 10, 1),
            fontSize: 32,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(game.size.x - 60, 20));

    add(_scoreTextComponent);

    final startSprite = await game.loadSprite('star.png');
    add(SpriteComponent(
        sprite: startSprite,
        position: Vector2(game.size.x - 100, 20),
        size: Vector2.all(32),
        anchor: Anchor.center));

    for (var i = 1; i <= game.health; i++) {
      final positionX = 40 * i;
      await add(HeartHealthCompinent(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), 20),
          size: Vector2.all(32)));
    }
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.starsCollected}';
  }
}
