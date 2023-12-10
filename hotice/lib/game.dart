import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:hotice/ball.dart';
import 'package:hotice/player.dart';

class MyGame extends FlameGame with HasCollisionDetection, PanDetector {
  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  /// used to determine whether to play the sound or not
  bool _hasUserInteracted = false;

  MyGame({
    required this.onBackToLobby,
    required this.onPlayerStateChange,
  });

  final void Function(
    double x,
    int heatPoint,
  ) onPlayerStateChange;

  late Random _random;

  bool _isInGame = false;

  /// `Player` instance of the player
  late Player _player;

  /// `Player` instance of the opponent
  late Player _opponent;

  late final flame_image.Image _flameImage;
  late final flame_image.Image _snowballImage;

  late final double _screenWidth;

  /// Y cordinates of the players
  late final double _playerY;

  @override
  Future<void>? onLoad() async {
    _screenWidth = size.x;
    final screenHeight = size.y;
    _playerY = screenHeight * 3 / 4;

    _flameImage = await images.load('flame.png');
    _snowballImage = await images.load('snow.png');

    FlameAudio.bgm.stop();
    if (_hasUserInteracted) await FlameAudio.bgm.play('intro.mp3');

    await super.onLoad();
  }

  Future<void> onPlayerLost() async {
    FlameAudio.bgm.stop();
    if (_hasUserInteracted) await FlameAudio.play('lost.wav');
    _isInGame = false;
    _player.isGameOver = true;
  }

  final void Function() onBackToLobby;

  Future<void> start({
    required int seed,
    required bool isPlayerLeft,
  }) async {
    _random = Random(seed);

    _isInGame = true;

    final leftPosition = _screenWidth / 4;
    final rightPosition = _screenWidth * 3 / 4;
    // Add the player
    _player = Player(
      isMe: true,
      onPlayerStateChange: (x, heatPoint) {
        onPlayerStateChange(x, heatPoint);
      },
      initialPosition:
          Vector2(isPlayerLeft ? leftPosition : rightPosition, _playerY),
      onPlayerLost: onPlayerLost,
    );

    add(_player);

    // Add the opponent
    _opponent = Player(
      isMe: false,
      onPlayerStateChange: (_, __) {},
      initialPosition:
          Vector2(isPlayerLeft ? rightPosition : leftPosition, _playerY),
      onPlayerLost: () {},
    );
    add(_opponent);

    FlameAudio.bgm.stop();
    if (_hasUserInteracted) await FlameAudio.bgm.play('ingame.mp3');

    _shootBullets();
  }

  void setOpponent({
    required double x,
    required int heatPoint,
  }) {
    _opponent.setPosition(x);
    _opponent.setOpponentHeatPoint(heatPoint);
    if (!_opponent.isPlayerAlive) {
      FlameAudio.bgm.stop();
      if (_hasUserInteracted) FlameAudio.play('won.wav');
      _isInGame = false;
      _player.isGameOver = true;
    }
  }

  int _newBallDelay = 300;

  Future<void> _shootBullets() async {
    if (!_isInGame) {
      return;
    }
    // Add flame
    add(Ball(
      image: _flameImage,
      initialPosition: Vector2(_random.nextDouble() * _screenWidth, 0),
      isFlame: true,
      velocity: Vector2(0, _random.nextDouble() * 100 + 80),
    ));

    // Add snow
    add(Ball(
      image: _snowballImage,
      initialPosition: Vector2(_random.nextDouble() * _screenWidth, 0),
      isFlame: false,
      velocity: Vector2(0, _random.nextDouble() * 100 + 80),
    ));

    await Future.delayed(
        Duration(milliseconds: _random.nextInt(200) + _newBallDelay));
    if (_newBallDelay > 50) {
      _newBallDelay--;
    }

    _shootBullets();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    if (!_hasUserInteracted) {
      _hasUserInteracted = true;
      _player.canPlaySound = true;
      if (_isInGame) {
        FlameAudio.bgm.play('ingame.mp3');
      } else {
        FlameAudio.bgm.play('intro.mp3');
      }
    }
    if (!_isInGame) {
      return;
    }

    final distance = info.delta.global.x;
    _player.setPosition(_player.position.x + distance);
    onPlayerStateChange(
      _player.position.x,
      _player.heatPoint,
    );
  }
}
