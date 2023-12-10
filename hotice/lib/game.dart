import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flutter/material.dart';
import 'package:hotice/ball.dart';
import 'package:hotice/player.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  final Random _random = Random();

  /// `Player` instance of the player
  late Player _player;

  /// `Player` instance of the opponent
  late Player _opponent;

  late final flame_image.Image _flameImage;
  late final flame_image.Image _snowballImage;

  late final double _screenWidth;

  @override
  Future<void>? onLoad() async {
    _screenWidth = size.x;
    final screenHeight = size.y;
    final playerImage = await images.load('player.png');

    // Add the player
    _player = Player(
      isMe: true,
      initialPosition: Vector2(_screenWidth / 4, screenHeight * 3 / 4),
    );
    final spriteSize = Vector2.all(Player.radius * 2);
    _player.add(SpriteComponent(sprite: Sprite(playerImage), size: spriteSize));
    add(_player);

    // Add the opponent
    _opponent = Player(
      isMe: false,
      initialPosition: Vector2(_screenWidth * 3 / 4, screenHeight * 3 / 4),
    );
    _opponent.add(SpriteComponent.fromImage(playerImage, size: spriteSize));
    add(_opponent);

    _flameImage = await images.load('flame.png');
    _snowballImage = await images.load('snow.png');

    await super.onLoad();

    _shootBullets();
  }

  Future<void> _shootBullets() async {
    add(Bullet(
      image: _flameImage,
      initialPosition: Vector2(_random.nextDouble() * _screenWidth, 0),
      isFire: true,
    ));
    add(Bullet(
      image: _snowballImage,
      initialPosition: Vector2(_random.nextDouble() * _screenWidth, 0),
      isFire: false,
    ));

    await Future.delayed(Duration(milliseconds: _random.nextInt(200) + 300));

    _shootBullets();
  }
}
