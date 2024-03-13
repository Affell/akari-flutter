import 'package:akari/models/database.dart';
import 'package:flutter/material.dart';
import 'models/grid.dart';

DatabaseManager databaseManager = DatabaseManager();

Future main() async {
  databaseManager.initDatabase();

  runApp(const MainApp());
}

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
  final Grid grid1 = Grid.createGrid(0, 10);

  MyGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return grid1.displayGrid();
  }
}
