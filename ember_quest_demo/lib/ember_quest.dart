import 'dart:async';
import 'dart:ui';

import 'package:ember_quest_demo/actors/ember.dart';
import 'package:ember_quest_demo/managers/segment_manager.dart';
import 'package:ember_quest_demo/overlays/hud.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'actors/water_enemy.dart';
import 'objects/ground_block.dart';
import 'objects/platform_block.dart';
import 'objects/star.dart';

class EmberQuestGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  EmberQuestGame();

  int startsCollected = 0;
  int health = 3;

  late EmberPlayer _ember;
  double objectSpeed = 0.0;
  final world = World();
  late final CameraComponent cameraComponent;

  late double lastBlockXposition = 0.0;
  late UniqueKey lastBlockKey;

  int starsCollected = 0;

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
    print('onLoad');
    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, world]);

    initializeGame(true);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void initializeGame(bool loadHub) {
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (i * 640).toDouble());
    }

    _ember = EmberPlayer(position: Vector2(128, canvasSize.y - 70));
    world.add(_ember);
    if (loadHub) {
      cameraComponent.viewport.add(Hub());
    }
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          add(GroundBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case PlatformBlock:
          add(PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ));
          break;
        case Star:
          add(Star(gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case WaterEnemy:
          add(WaterEnemy(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        default:
      }
    }
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
      print('GameOver');
    }
    super.update(dt);
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }
}
