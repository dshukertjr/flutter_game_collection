import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';
import 'package:watermelongame/fruit.dart';

void main() {
  runApp(
    const SafeArea(
        child: GameWidget.controlled(gameFactory: Forge2DExample.new)),
  );
}

class Forge2DExample extends Forge2DGame with PanDetector {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.gravity = Vector2(0, 180);
    world.addAll(_createBoundaries());
  }

  Vector2 _panPosition = Vector2.zero();

  @override
  void onPanDown(DragDownInfo info) {
    _panPosition = info.eventPosition.widget;
    print(info.raw.localPosition.toVector2());
    // print(_panPosition);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // super.onPanUpdate(info);
    _panPosition = info.eventPosition.widget;
    // print(_panPosition);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // print(_panPosition);
    // world.add(Fruit(position: _panPosition));
    world.add(Fruit(position: Vector2(0, 0)));
  }

  List<Component> _createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
