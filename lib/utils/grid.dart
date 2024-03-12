import 'package:flutter/material.dart';

class Grid {
  int _difficulty;
  int _gridSize;
  List<List<int>> startGrid = [];
  List<List<int>> currentGrid = [];

  Grid({
    required int difficulty,
    required int gridSize,
  })  : _difficulty = difficulty,
        _gridSize = gridSize;

  void generateGrid() {
    startGrid = [
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0]
    ];

    print(startGrid);
  }
}

void main() {}
