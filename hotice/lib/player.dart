import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  Player({
    required bool isMe,
    required Vector2 initialPosition,
  })  : _isMyPlayer = isMe,
        super(
          position: initialPosition,
        );
  final bool _isMyPlayer;

  static const radius = 30.0;

  @override
  Future<void>? onLoad() async {
    anchor = Anchor.center;
    width = radius * 2;
    height = radius * 2;

    add(CircleHitbox());
    await super.onLoad();
  }
}
