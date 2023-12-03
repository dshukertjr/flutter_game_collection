import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Fruit extends BodyComponent with ContactCallbacks, TapCallbacks {
  Fruit({
    required Vector2 position,
  })  : _position = position,
        super();

  final Vector2 _position;
  double _radius = 2;

  bool _changedFruit = false;

  @override
  Body createBody() {
    bodyDef = BodyDef(
      angularDamping: 0.8,
      position: _position,
      type: BodyType.dynamic,
      userData: this,
    );

    fixtureDefs = [
      FixtureDef(
        CircleShape()..radius = _radius,
        restitution: 0.6,
        friction: 0.4,
      ),
    ];

    return super.createBody();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Fruit) {
      if (body.linearVelocity.length > other.body.linearVelocity.length) {
        removeFromParent();
      } else {
        _changedFruit = true;
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    if (_changedFruit) {
      _radius = _radius * 1.3;
      body.createFixtureFromShape(
        CircleShape()..radius = _radius.toDouble(),
        restitution: 0.6,
        friction: 0.4,
      );
      _changedFruit = false;
    }
    super.update(dt);
  }

  @override
  void endContact(Object other, Contact contact) {
    print('end contact');
    super.endContact(other, contact);
  }
}
