import 'package:flutter/material.dart';
import 'models/grid.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Akari Game'),
        ),
        body: MyGridWidget(),
      ),
    );
  }
}

class MyGridWidget extends StatelessWidget {
  final Grid grid1 = Grid(difficulty: 0, gridSize: 7);

  MyGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return grid1.displayGrid();
  }
}
