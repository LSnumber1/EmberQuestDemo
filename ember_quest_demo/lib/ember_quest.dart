import 'dart:async';

import 'package:ember_quest_demo/actors/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class EmberQuestGame extends FlameGame {
  EmberQuestGame();

  late EmberPlayer _ember;
  final world = World();
  late final CameraComponent cameraComponent;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);

    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);

    _ember = EmberPlayer(position: Vector2(128, canvasSize.y - 70));
    world.add(_ember);
  }
}
