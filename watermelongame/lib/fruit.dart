import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Fruit extends BodyComponent with ContactCallbacks, TapCallbacks {
  Fruit({
    required Vector2 initialPosition,
    required this.type,
  })  : _initialPosition = initialPosition,
        super();

  FruitsType type;

  static const _restitution = 0.2;
  static const _friction = 0.4;

  /// initial position of the fruit
  final Vector2 _initialPosition;

  /// Whether to increment the fruit in the next game loop
  bool _incrementFruit = false;

  @override
  Body createBody() {
    paint = Paint()..color = type.color;

    bodyDef = BodyDef(
      angularDamping: 0.8,
      linearDamping: 0.3,
      position: _initialPosition,
      type: BodyType.dynamic,
      userData: this,
    );

    fixtureDefs = [
      FixtureDef(
        CircleShape()..radius = type.radius,
        restitution: _restitution,
        friction: _friction,
      ),
    ];

    return super.createBody();
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is Fruit) {
      if (type != other.type) {
        return;
      }
      if (body.linearVelocity.length > other.body.linearVelocity.length) {
        // remove the fast moving one.
        removeFromParent();
      } else if (type != FruitsType.waterMelon) {
        _incrementFruit = true;
      }
    }
  }

  @override
  void update(double dt) {
    if (_incrementFruit) {
      type = type.increment();

      paint = Paint()..color = type.color;
      body.destroyFixture(body.fixtures.first);

      body.createFixtureFromShape(
        CircleShape()..radius = type.radius,
        restitution: _restitution,
        friction: _friction,
      );
      _incrementFruit = false;
    }
    super.update(dt);
  }
}

enum FruitsType {
  grape(
    radius: 1.5,
    color: Colors.purple,
  ),
  plum(
    radius: 2,
    color: Colors.red,
  ),
  orange(
    radius: 2.5,
    color: Colors.orange,
  ),
  lemon(
    radius: 3,
    color: Colors.yellow,
  ),
  kiwi(
    radius: 4,
    color: Colors.green,
  ),
  tomato(
    radius: 4.5,
    color: Colors.red,
  ),
  peach(
    radius: 5,
    color: Colors.amber,
  ),
  grapefruit(
    radius: 5.5,
    color: Colors.amberAccent,
  ),
  cutWatermMlon(
    radius: 6,
    color: Colors.red,
  ),
  waterMelon(
    radius: 6.5,
    color: Colors.green,
  );

  final double radius;
  final Color color;

  const FruitsType({
    required this.radius,
    required this.color,
  });

  FruitsType increment() {
    if (this == FruitsType.waterMelon) {
      throw RangeError('increment can not be called on a waterMelon.');
    }
    return FruitsType.values[index + 1];
  }

  static getRandomFruitType(int maxIndex) {
    final index = Random().nextInt(maxIndex);
    return FruitsType.values.singleWhere((element) => element.index == index);
  }
}
