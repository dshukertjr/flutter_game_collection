import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hotice/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://wfmycwhninbfxjoygiyd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbXljd2huaW5iZnhqb3lnaXlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDIyMDU5NzcsImV4cCI6MjAxNzc4MTk3N30.hbB6GNEifQFGSLQs-aztE_TXB_u0wLFd-T_gyp9IHWs',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 30),
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ice Flame Mountain',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MyGame _game;

  final String _myPlayerId = const Uuid().v4();

  RealtimeChannel? _lobbyChannel;
  RealtimeChannel? _gameChannel;
  String? _gameId;

  @override
  void initState() {
    super.initState();
    _startLobbyListener();
    _game = MyGame(
      onBackToLobby: _startLobbyListener,
      onPlayerStateChange: (x, heatPoint) async {
        if (_gameChannel == null) {
          return;
        }
        final res =
            await _gameChannel!.sendBroadcastMessage(event: _gameId!, payload: {
          'x': x,
          'heat_point': heatPoint,
        });

        if (heatPoint >= 4 || -4 >= heatPoint) {
          if (res != ChannelResponse.ok) {
            _sendLostMessage(x: x, heatPoint: heatPoint);
          }
        }
        if (heatPoint <= -4 || heatPoint >= 4) {
          // TODO handle player lost
        }
      },
    );
  }

  Future<void> _sendLostMessage({
    required double x,
    required int heatPoint,
  }) async {
    final res =
        await _gameChannel!.sendBroadcastMessage(event: _gameId!, payload: {
      'x': x,
      'heat_point': heatPoint,
    });

    if (res != ChannelResponse.ok) {
      await Future.delayed(const Duration(milliseconds: 10));
      _sendLostMessage(x: x, heatPoint: heatPoint);
    }
  }

  void _startLobbyListener() {
    if (_gameChannel != null) {
      supabase.removeChannel(_gameChannel!);
    }

    _lobbyChannel = supabase.channel('lobby',
        opts: const RealtimeChannelConfig(
          self: true,
        ));
    _lobbyChannel!
        .onPresenceSync((payload) {
          final presenceState = _lobbyChannel!.presenceState();

          // find player with player ID less than mine.
          final otherPlayerIds = presenceState
              .map((e) => e.presences.first.payload['player_id'] as String)
              .where((element) => element != _myPlayerId)
              .where((element) => element.compareTo(_myPlayerId) > 0);
          if (otherPlayerIds.isEmpty) {
            return;
          }
          final gameId = const Uuid().v4();
          _lobbyChannel!.sendBroadcastMessage(event: 'start_game', payload: {
            'players': [otherPlayerIds.first, _myPlayerId],
            'game_id': gameId,
          });
        })
        .onBroadcast(
            event: 'start_game',
            callback: (payload) {
              final players = List<String>.from(payload['players'] as List);

              // check if it's 2 players
              if (players.length != 2) {
                return;
              }

              final isMyGame = players.contains(_myPlayerId);
              if (!isMyGame) {
                return;
              }

              final opponentId =
                  players.singleWhere((element) => element != _myPlayerId);

              _gameId = payload['game_id'] as String;

              _startGameListener();
              final seed = _gameId!.codeUnits
                  .reduce((value, element) => value + element);

              _game.start(
                seed: seed,
                isPlayerLeft: opponentId.compareTo(_myPlayerId) > 0,
              );
            })
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _lobbyChannel!.track({
              'player_id': _myPlayerId,
            });
          }
        });
  }

  void _startGameListener() {
    supabase.removeChannel(_lobbyChannel!);

    _gameChannel = supabase
        .channel('game', opts: const RealtimeChannelConfig(ack: true))
        .onBroadcast(
            event: _gameId!,
            callback: (payload) {
              final x = payload['x'] as double;
              final heatPoint = payload['heat_point'] as int;
              _game.setOpponent(
                x: x,
                heatPoint: heatPoint,
              );
              if (heatPoint >= 4 || -4 >= heatPoint) {
                // TODO handle player won
              }
            })
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpeg', fit: BoxFit.cover),
          GameWidget(game: _game),
        ],
      ),
    );
  }
}
