import 'dart:async';

import 'package:ember_quest_demo/actors/water_enemy.dart';
import 'package:ember_quest_demo/ember_quest.dart';
import 'package:ember_quest_demo/objects/ground_block.dart';
import 'package:ember_quest_demo/objects/platform_block.dart';
import 'package:ember_quest_demo/objects/star.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame>, KeyboardHandler, CollisionCallbacks {
  EmberPlayer({required super.position})
      : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  // TODO: implement debugMode
  bool get debugMode => true;

  int horizontalDirection = 0;
  final Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;

  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  bool hasJumped = false;
  bool hitByEnemy = false;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.12,
        textureSize: Vector2.all(16),
      ),
    );
    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;

    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    game.objectSpeed = 0;

    if (position.x - 72 <= 0 && horizontalDirection < 0) {
      velocity.x = 0;
    }
    if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
      velocity.x = 0;
      game.objectSpeed = -moveSpeed;
    }

    velocity.y += gravity;
    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }

    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

    position += velocity * dt;

    if (position.y > game.size.y + size.y) {
      game.health = 0;
    }

    if (game.health == 0) {
      removeFromParent();
    }

    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;
        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is Star) {
      other.removeFromParent();
      game.starsCollected++;
    }

    if (other is WaterEnemy) {
      hit();
    }

    super.onCollision(intersectionPoints, other);
  }

  void hit() {
    if (!hitByEnemy) {
      game.health--;
      hitByEnemy = true;
    }
    add(OpacityEffect.fadeOut(
      EffectController(alternate: true, duration: 0.1, repeatCount: 6),
    )..onComplete = () {
        hitByEnemy = false;
      });
  }
}
