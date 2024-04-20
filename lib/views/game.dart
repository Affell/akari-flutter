import 'dart:convert';
import 'package:akari/models/grid.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Game extends StatelessWidget {
  final int size;
  final int difficulty;

  Game({required this.size, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akari Game'),
      ),
      body: MyGridWidget(size: size, difficulty: difficulty),
    );
  }
}

class MyGridWidget extends StatelessWidget {
  final int size;
  final int difficulty;

  MyGridWidget({required this.size, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return GridWidget(
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

  Game2({Key? key, required this.gameData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akari Game'),
      ),
      body: MyGridWidget2(gameData: gameData),
    );
  }
}

class MyGridWidget2 extends StatelessWidget {
  final Map<String, Object?> gameData;

  MyGridWidget2({required this.gameData});

  @override
  Widget build(BuildContext context) {
    return GridWidget(
      grid: Grid.loadGrid(
        creationTime: gameData['creation_time'] as int,
        time: gameData['time_spent'] as int,
        difficulty: gameData['difficulty'] as int,
        gridSize: gameData['size'] as int,
        startGrid: (jsonDecode(gameData['start_grid'] as String) as List)
            .map((item) => (item as List).map((i) => i as int).toList())
            .toList(),
        lights: (jsonDecode(gameData['lights'] as String) as List)
            .map((item) => Tuple2<int, int>(
                (item as List)[0] as int, (item as List)[1] as int))
            .toList(),
        actionsPassees: jsonDecode(gameData["actions_passees"] as String)
            .map<List<int>>((l) => List<int>.from(l))
            .toList()
            .map<Tuple2<int, int>>((e) => Tuple2(e[0] as int, e[1] as int))
            .toList(),
        actionsFutures: jsonDecode(gameData["actions_futures"] as String)
            .map<List<int>>((l) => List<int>.from(l))
            .toList()
            .map<Tuple2<int, int>>((e) => Tuple2(e[0] as int, e[1] as int))
            .toList(),
      ),
    );
  }
}
