import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hotice/game.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      title: 'Flutter Demo',
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

  @override
  void initState() {
    super.initState();

    final channel = supabase.channel('name');
    channel.onPresenceSync((payload) {
      final presenceState = channel.presenceState();
      print(presenceState);
    });

    _game = MyGame();
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
