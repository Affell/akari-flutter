import 'package:akari/models/database.dart';
import 'package:flutter/material.dart';
import 'models/grid.dart';
import 'package:just_audio/just_audio.dart';

DatabaseManager databaseManager = DatabaseManager();
final player = AudioPlayer();

Future main() async {
  databaseManager.initDatabase();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    player.setUrl('asset:lib/assets/musics/backgroundMusic.mp3');

    player.setVolume(0.5);

    player.setLoopMode(LoopMode.all);
    player.play();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Akari Game'),
        ),
        body: const MyGridWidget(),
      ),
    );
  }
}

class MyGridWidget extends StatelessWidget {
  const MyGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridWidget(
      grid: Grid.createGrid(
          difficulty: 0,
          gridSize: 10,
          creationTime: DateTime.now().millisecondsSinceEpoch ~/ 1000),
    );
  }
}
