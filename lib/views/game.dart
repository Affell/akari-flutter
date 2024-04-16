import 'package:akari/models/grid.dart';
import 'package:flutter/material.dart';

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