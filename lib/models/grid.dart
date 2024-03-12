import 'dart:math';

import 'package:flutter/material.dart';

class Grid {
  int _difficulty; //0 : Easy | 1 : Medium | 2 : Hard
  int _gridSize;
  List<List<int>> startGrid = [];
  List<List<int>> currentGrid = [];
  List<double> ratiosMursSurface = [0.3, 0.2, 0.1];
  List<double> ratiosChiffreMurs = [0.6, 0.7, 0.8];

  Grid({
    required int difficulty,
    required int gridSize,
  })  : _difficulty = difficulty,
        _gridSize = gridSize {
    generateGrid();
  }

  void generateGrid() {
    //Initialisation des listes
    for (int i = 0; i < _gridSize; i++) {
      List<int> startRow = [];
      for (int j = 0; j < _gridSize; j++) {
        startRow.add(0);
      }
      startGrid.add(startRow);
    }

    //Calcul du nombre de murs à placer
    int nbMurs =
        (ratiosMursSurface[_difficulty] * (_gridSize * _gridSize)) as int;
    //Placement des murs
    Random rand = Random();
    int cpt = 0, x = 0, y = 0;
    while (cpt < nbMurs) {
      do {
        x = rand.nextInt(_gridSize);
        y = rand.nextInt(_gridSize);
      } while (startGrid[x][y] != 0);

      startGrid[x][y] = -1;
      cpt++;
    }
    //Placement des ampoules
    int nbCasesAllumees = 0;
    int nbCasesTotalEteintes = _gridSize * _gridSize -
        cpt; //Nombre de cases à allumer (toute la grille - les murs)
    x = 0;
    y = 0;
    bool murSurChemin = false;
    while (nbCasesAllumees < nbCasesTotalEteintes) {
      //Placement d'ampoules
      do {
        x = rand.nextInt(_gridSize);
        y = rand.nextInt(_gridSize);
      } while (startGrid[x][y] != 0);
      startGrid[x][y] = -3;
      nbCasesTotalEteintes--; //Une case en moins à allumer car on y place une ampoule
      //Actualisation du nombre de cases éclairées
      murSurChemin = false;
      //Colonne vers le bas
      for (int j = x + 1; j < _gridSize && !murSurChemin; ++j) {
        if (startGrid[j][y] == -1) {
          murSurChemin = true;
        }
        if (murSurChemin == false && startGrid[j][y] == 0) {
          startGrid[j][y] = -4;
          nbCasesAllumees++;
        }
      }
      murSurChemin = false;
      //Colonne vers le haut
      for (int j = x - 1; j >= 0 && !murSurChemin; --j) {
        if (startGrid[j][y] == -1) {
          murSurChemin = true;
        }
        if (murSurChemin == false && startGrid[j][y] == 0) {
          startGrid[j][y] = -4;
          nbCasesAllumees++;
        }
      }
      murSurChemin = false;
      //Ligne vers la droite
      for (int j = y + 1; j < _gridSize && !murSurChemin; ++j) {
        if (startGrid[x][j] == -1) {
          murSurChemin = true;
        }
        if (murSurChemin == false && startGrid[x][j] == 0) {
          startGrid[x][j] = -4;
          nbCasesAllumees++;
        }
      }
      murSurChemin = false;
      //Ligne vers la gauche
      for (int j = y - 1; j >= 0 && !murSurChemin; --j) {
        if (startGrid[x][j] == -1) {
          murSurChemin = true;
        }
        if (murSurChemin == false && startGrid[x][j] == 0) {
          startGrid[x][j] = -4;
          nbCasesAllumees++;
        }
      }
    }
    //On remet à 0 les cases temporairement mises à 4
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (startGrid[i][j] == -4) {
          startGrid[i][j] = 0;
        }
      }
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
