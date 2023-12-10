import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flame_audio/flame_audio.dart';
import 'package:hotice/ball.dart';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  Player({
    required this.onPlayerStateChange,
    required bool isMe,
    required Vector2 initialPosition,
    required this.onPlayerLost,
  })  : _isMyPlayer = isMe,
        super(
          anchor: Anchor.center,
          position: initialPosition,
        );

  bool canPlaySound = false;

  bool isGameOver = false;

  /// Callback for when the player has lost
  ///
  /// Only used if it's my player
  final void Function() onPlayerLost;

  final void Function(
    double x,
    int heatPoint,
  ) onPlayerStateChange;

  final bool _isMyPlayer;

  late final List<flame_image.Image> _playerImages;

  /// Positive means it's hot, negative means it's cold
  ///
  /// When it's 4 or -4, the player loses
  int heatPoint = 0;

  late final SpriteComponent _spriteComponent;

  @override
  Future<void>? onLoad() async {
    width = 50;
    height = 100;

    add(
      RectangleHitbox(
        size: Vector2(width, height),
        anchor: Anchor.center,
      ),
    );

    final imagesLoader = Images();
    _playerImages = await Future.wait([
      imagesLoader.load('snow2.png'),
      imagesLoader.load('snow1.png'),
      imagesLoader.load('normal.png'),
      imagesLoader.load('flame1.png'),
      imagesLoader.load('flame2.png'),
    ]);

    final spriteSize = Vector2.all(100);
    _spriteComponent = SpriteComponent(
      sprite: Sprite(_playerImages[2]),
      size: spriteSize,
      anchor: Anchor.center,
    );

    add(
      _spriteComponent..opacity = _isMyPlayer ? 1 : 0.7,
    );

    await super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!_isMyPlayer) {
      return;
    }
    if (!isPlayerAlive) {
      return;
    }
    if (isGameOver) {
      return;
    }
    if (other is Ball && other.isFlame) {
      other.hasBeenHit = true;
      other.removeFromParent();
      final isDamage = heatPoint >= 0;
      heatPoint++;
      _onHitBall(isDamange: isDamage);
    } else if (other is Ball && !other.isFlame) {
      other.hasBeenHit = true;
      other.removeFromParent();
      final isDamage = heatPoint <= 0;
      heatPoint--;
      _onHitBall(isDamange: isDamage);
    }
  }

  void _updateSprite() {
    if (heatPoint <= -4) {
      _spriteComponent.sprite = Sprite(_playerImages[0]);
    } else if (heatPoint < 0) {
      _spriteComponent.sprite = Sprite(_playerImages[1]);
    } else if (heatPoint == 0) {
      _spriteComponent.sprite = Sprite(_playerImages[2]);
    } else if (heatPoint >= 4) {
      _spriteComponent.sprite = Sprite(_playerImages[4]);
    } else if (heatPoint > 0) {
      _spriteComponent.sprite = Sprite(_playerImages[3]);
    }
  }

  void _onHitBall({required bool isDamange}) {
    if (!_isMyPlayer) {
      return;
    }

    _updateSprite();

    if (isDamange) {
      if (canPlaySound) FlameAudio.play('damage.wav');
    } else {
      if (canPlaySound) FlameAudio.play('heal.wav');
    }
    onPlayerStateChange(position.x, heatPoint);
    if (!isPlayerAlive) {
      onPlayerLost();
    }
  }

  bool get isPlayerAlive => 4 > heatPoint && heatPoint > -4;

  /// Only called for opponents
  void setOpponentHeatPoint(int newHeatPoint) {
    heatPoint = newHeatPoint;
    _updateSprite();
    _updateSprite();
  }

  void setPosition(double x) {
    final isGoingToRight = x > position.x;
    position.x = x;
    if (isGoingToRight) {
      if (_spriteComponent.isFlippedHorizontally) {
        _spriteComponent.flipHorizontally();
      }
    } else {
      if (!_spriteComponent.isFlippedHorizontally) {
        _spriteComponent.flipHorizontally();
      }
    }
  }
}
