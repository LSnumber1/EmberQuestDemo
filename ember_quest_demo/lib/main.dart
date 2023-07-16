import 'package:ember_quest_demo/ember_quest.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GameWidget<EmberQuestGame>.controlled(
      gameFactory: EmberQuestGame.new));
}
