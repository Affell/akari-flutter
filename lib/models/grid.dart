import 'package:akari/models/action.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Grid {
  final int creationTime;
  final int difficulty;
  final int gridSize;
  List<List<int>> startGrid = [];
  List<Tuple2<int, int>> lights = [];
  List<GridAction> actions = [];

  Grid(this.creationTime, this.difficulty, this.gridSize, this.startGrid,
      this.lights, this.actions);

  Grid.createGrid(
    this.difficulty,
    this.gridSize,
  ) : creationTime = DateTime.now().millisecondsSinceEpoch {
    generateGrid();
  }

  void generateGrid() {
    for (int i = 0; i < gridSize; i++) {
      List<int> startRow = [];
      for (int j = 0; j < gridSize; j++) {
        startRow.add(0);
      }
      startGrid.add(startRow);
    }
  }

  Widget displayGrid() {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
      itemCount: gridSize * gridSize,
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ gridSize;
        int col = index % gridSize;
        return GridTile(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Center(
              child: Text('${startGrid[row][col]}'),
            ),
          ),
        );
      },
    );
  }
}
