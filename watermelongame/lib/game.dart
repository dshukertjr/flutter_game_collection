import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:watermelongame/fruit.dart';

class StandbyFruit extends PositionComponent {
  final Vector2 _initialPosition;

  FruitsType _fruitType = FruitsType.grape;

  bool _isHidden = false;

  StandbyFruit({required Vector2 initialPosition})
      : _initialPosition = initialPosition;

  @override
  FutureOr<void> onLoad() {
    size = Vector2(2, 2);
    position = _initialPosition;
    return super.onLoad();
  }

  Future<void> changeFruit(FruitsType newType) async {
    _fruitType = newType;
    _isHidden = true;
    await Future.delayed(const Duration(seconds: 1));
    _isHidden = false;
  }

  @override
  void render(Canvas canvas) {
    if (!_isHidden) {
      canvas.drawCircle(
        const Offset(0, 0),
        _fruitType.radius,
        Paint()..color = _fruitType.color,
      );
    }
  }
}

class Forge2DExample extends Forge2DGame with PanDetector {
  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.gravity = Vector2(0, 180);
    world.addAll(_createBoundaries());

    _nextFruitIndicator = BodyComponent(
        bodyDef: BodyDef(
          position: _getBodyPosition(Vector2(size.x - 20, 20)),
          type: BodyType.static,
        ),
        fixtureDefs: [
          FixtureDef(
            CircleShape()..radius = 2,
          ),
        ])
      ..paint = (Paint()..color = _nextFruitType.color);

    world.add(_nextFruitIndicator);

    _dropY = size.y / 5;

    _standbyFruit = StandbyFruit(
        initialPosition: _getBodyPosition(Vector2(size.x / 2, _dropY)));

    world.add(_standbyFruit);
  }

  late final BodyComponent _nextFruitIndicator;

  late StandbyFruit _standbyFruit;

  /// Y coordinates of where the fruit it dropped
  late final double _dropY;

  Vector2 _panPosition = Vector2.zero();
  FruitsType _nextFruitType = FruitsType.grape;

  @override
  void onPanDown(DragDownInfo info) {
    super.onPanDown(info);
    _panPosition = info.eventPosition.widget;
    _standbyFruit.position = _getBodyPosition(Vector2(_panPosition.x, _dropY));
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    _panPosition = info.eventPosition.widget;
    _standbyFruit.position = _getBodyPosition(Vector2(_panPosition.x, _dropY));
  }

  @override
  void onPanCancel() {
    super.onPanCancel();
    _dropFruit();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    _dropFruit();
  }

  /// Used to convert pan position to body position
  Vector2 _getBodyPosition(Vector2 panPosition) {
    final visibleRect = camera.visibleWorldRect;
    final worldAndCameraRatio = (visibleRect.right - visibleRect.left) / size.x;

    final topLeft = visibleRect.topLeft.toVector2();

    return panPosition * worldAndCameraRatio + topLeft;
  }

  void _dropFruit() {
    final dropPosition = _getBodyPosition(Vector2(_panPosition.x, _dropY));
    world.add(Fruit(
      initialPosition: dropPosition,
      type: _nextFruitType,
    ));

    // Generate the next fruit
    if (world.children.whereType<Fruit>().isNotEmpty) {
      final maxIndex = min(
          world.children
              .whereType<Fruit>()
              .map((e) => (e).type.index)
              .reduce(max),
          4);
      if (maxIndex == 0) {
        _nextFruitType = FruitsType.grape;
      } else {
        _nextFruitType = FruitsType.getRandomFruitType(maxIndex);
      }
    } else {
      _nextFruitType = FruitsType.grape;
    }
    _nextFruitIndicator.paint = Paint()..color = _nextFruitType.color;
    _standbyFruit.changeFruit(_nextFruitType);
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
