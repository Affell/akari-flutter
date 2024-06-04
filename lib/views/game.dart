import 'dart:convert';
import 'package:akari/models/grid.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Game extends StatelessWidget {
  final int size;
  final int difficulty;

  const Game({super.key, required this.size, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akari Game'),
      ),
      body: MyGridWidget(size: size, difficulty: difficulty),
    );
  }
}

class MyGridWidget extends StatelessWidget {
  final int size;
  final int difficulty;

  const MyGridWidget({super.key, required this.size, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return GridWidget(
      isOnlineGame: false,
      grid: Grid.createGrid(
        difficulty: difficulty,
        gridSize: size,
        creationTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );
  }
}

class Game2 extends StatelessWidget {
  final Map<String, Object?> gameData;

  const Game2({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Akari Game'),
        ),
        body: MyGridWidget2(gameData: gameData),
      ),
    );
  }
}

typeGame getTypeGameFromLoad(String type) {
  if (type == "typeGame.Solo") {
    return typeGame.Solo;
  } else {
    return typeGame.VS;
  }
}

class MyGridWidget2 extends StatelessWidget {
  final Map<String, Object?> gameData;

  const MyGridWidget2({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return GridWidget(
      isOnlineGame: false,
      grid: Grid.loadGrid(
        creationTime: gameData['creation_time'] as int,
        time: gameData['time_spent'] as int,
        difficulty: gameData['difficulty'] as int,
        gridSize: gameData['size'] as int,
        type: getTypeGameFromLoad(gameData['type'] as String),
        startGrid: (jsonDecode(gameData['start_grid'] as String) as List)
            .map((item) => (item as List).map((i) => i as int).toList())
            .toList(),
        lights: (jsonDecode(gameData['lights'] as String) as List)
            .map((item) => Tuple2<int, int>(
                (item as List)[0] as int, (item as List)[1] as int))
            .toList(),
        pastActions: jsonDecode(gameData["actions_passees"] as String)
            .map<List<int>>((l) => List<int>.from(l))
            .toList()
            .map<Tuple2<int, int>>((e) => Tuple2(e[0] as int, e[1] as int))
            .toList(),
        futureActions: jsonDecode(gameData["actions_futures"] as String)
            .map<List<int>>((l) => List<int>.from(l))
            .toList()
            .map<Tuple2<int, int>>((e) => Tuple2(e[0] as int, e[1] as int))
            .toList(),
      ),
    );
  }
}
