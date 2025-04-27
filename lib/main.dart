import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sync_10/game/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ignore: do_not_use_environment
  const url = String.fromEnvironment('SUPABASE_URL');
  // ignore: do_not_use_environment
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameWidget.controlled(gameFactory: Sync10Game.new),
    );
  }
}
