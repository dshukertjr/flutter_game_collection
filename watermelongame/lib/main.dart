import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:watermelongame/game.dart';

void main() {
  runApp(
    const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
      child: SafeArea(
          child: GameWidget.controlled(gameFactory: Forge2DExample.new)),
    ),
  );
}
