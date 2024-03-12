import 'package:flutter/material.dart';

class Grid {
  // int _difficulty;
  int _gridSize;
  List<List<int>> startGrid = [];
  List<List<int>> currentGrid = [];

  Grid({
    required int difficulty,
    required int gridSize,
  }) : // _difficulty = difficulty//,
        _gridSize = gridSize {
    generateGrid();
  }

  void generateGrid() {
    for (int i = 0; i < _gridSize; i++) {
      List<int> startRow = [];
      for (int j = 0; j < _gridSize; j++) {
        startRow.add(0);
      }
      startGrid.add(startRow);
    }
  }

  Widget displayGrid() {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _gridSize),
      itemCount: _gridSize * _gridSize,
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ _gridSize;
        int col = index % _gridSize;
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
