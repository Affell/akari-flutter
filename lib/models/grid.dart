import 'dart:math';

import 'package:akari/models/action.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

const List<double> ratiosMursSurface = [0.3, 0.2, 0.1];
const List<double> ratiosChiffreMurs = [0.6, 0.7, 0.8];

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

  bool isInGrid(int x, int y) {
    if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) {
      return false;
    } else {
      return true;
    }
  }

  void generateGrid() {
    for (int i = 0; i < gridSize; i++) {
      List<int> startRow = [];
      for (int j = 0; j < gridSize; j++) {
        startRow.add(0);
      }
      startGrid.add(startRow);
    }

    //Calcul du nombre de murs à placer
    int nbMurs =
        (ratiosMursSurface[difficulty] * (gridSize * gridSize)).round();

    //Placement des murs
    Random rand = Random();
    int cpt = 0, x = 0, y = 0;
    while (cpt < nbMurs) {
      do {
        x = rand.nextInt(gridSize);
        y = rand.nextInt(gridSize);
      } while (startGrid[x][y] != 0);

      startGrid[x][y] = -1;
      cpt++;
    }
    //Placement des ampoules
    int nbCasesAllumees = 0;
    int nbCasesTotalEteintes = gridSize * gridSize -
        cpt; //Nombre de cases à allumer (toute la grille - les murs)
    x = 0;
    y = 0;
    bool murSurChemin = false;
    while (nbCasesAllumees < nbCasesTotalEteintes) {
      //Placement d'ampoules
      do {
        x = rand.nextInt(gridSize);
        y = rand.nextInt(gridSize);
      } while (startGrid[x][y] != 0);
      startGrid[x][y] = -3;
      nbCasesTotalEteintes--; //Une case en moins à allumer car on y place une ampoule
      //Actualisation du nombre de cases éclairées
      murSurChemin = false;
      //Colonne vers le bas
      for (int j = x + 1; j < gridSize && !murSurChemin; ++j) {
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
      for (int j = y + 1; j < gridSize && !murSurChemin; ++j) {
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
    //On remet à -2 les cases temporairement mises à 4
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (startGrid[i][j] == -4) {
          startGrid[i][j] = -2;
        }
      }
    }
    //Mise en place des contraintes aux murs
    int nbContraintesTotal = (ratiosChiffreMurs[difficulty] * cpt).round();
    int nbContraintes = 0;
    //Placement du bon nombre de contraintes
    while (nbContraintes < nbContraintesTotal) {
      //Parcourt de la grille
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (startGrid[i][j] == -1) {
            //Si on a un mur
            if (rand.nextDouble() < ratiosChiffreMurs[difficulty]) {
              //Aléatoire
              startGrid[i][j] = -5; //Mur à placer
              nbContraintes++;
            }
          }
        }
      }
    }
    //Update des contraintes avec le nombre d'ampoules autour
    for (int j = 0; j < gridSize; j++) {
      for (int k = 0; k < gridSize; k++) {
        //Si on doit placer une contrainter
        if (startGrid[j][k] == -5) {
          int ampoulesNear = 0;
          int nbCasesVidesNear = 0;
          //On regarde au dessus, en dessous et sur les côtés le nombre d'ampoules et le nombre de cases vides
          if (isInGrid(k + 1, j)) {
            if (startGrid[j][k + 1] == -3) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j][k + 1] == -1) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k - 1, j)) {
            if (startGrid[j][k - 1] == -3) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j][k - 1] == -1) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k, j + 1)) {
            if (startGrid[j + 1][k] == -3) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j + 1][k] == -1) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k, j - 1)) {
            if (startGrid[j - 1][k] == -3) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j - 1][k] == -1) {
              nbCasesVidesNear++;
            }
          }
          //On retire les contraintes des murs qui ne sont pas à côté d'un emplacement possible
          if (nbCasesVidesNear != 0) {
            startGrid[j][k] = ampoulesNear;
          } else {
            startGrid[j][k] = -1;
          }
        }
      }
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
