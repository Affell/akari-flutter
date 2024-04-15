import 'dart:math';

import 'package:akari/models/action.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:just_audio/just_audio.dart';

const List<double> ratiosMursSurface = [0.3, 0.2, 0.1];
const List<double> ratiosChiffreMurs = [0.6, 0.7, 0.8];

final lampBuild = AudioPlayer();
final lampBreak = AudioPlayer();


class Grid {
  int difficulty;
  int gridSize;
  int creationTime;
  List<List<int>> startGrid = [];
  List<Tuple2<int, int>> lights = [];
  List<GridAction> actions = [];

  Grid.createGrid(
      {required this.difficulty,
      required this.gridSize,
      required this.creationTime}) {
    generateGrid();
  }

  Grid(this.creationTime, this.difficulty, this.gridSize, this.startGrid,
      this.lights, this.actions);

  //Méthodes

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
    //On remet à -2 les cases temporairement mises à -3 (les ampoules)
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (startGrid[i][j] == -3) {
          startGrid[i][j] = -2;
        }
      }
    }
  }

  /*
  This function checks a grid to determine if the solution grid is correct.
  If solution correct: true, else false.
*/
  bool solutionChecker(List<List<int>> grid) {
    int n = grid.length;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i][j] >= 0) {
          // Wall with condition
          int nb = 0; // Counter to count the number of bulbs around the cell
          if (i - 1 >= 0) {
            if (grid[i - 1][j] == -3) {
              // Condition to count bulbs north, south, east, west
              nb++;
            }
          }
          if (i + 1 < n) {
            if (grid[i + 1][j] == -3) {
              nb++;
            }
          }
          if (j - 1 >= 0) {
            if (grid[i][j - 1] == -3) {
              nb++;
            }
          }
          if (j + 1 < n) {
            if (grid[i][j + 1] == -3) {
              nb++;
            }
          }
          if (nb != grid[i][j]) {
            // If the expected number does not match the found number then return false
            return false;
          }
        }
        if (grid[i][j] == -3) {
          // If bulb, check that there is no adjacent bulb
          bool southWall = false; // South wall encountered
          bool northWall = false; // North wall encountered
          bool eastWall = false; // East wall encountered
          bool westWall = false; // West wall encountered
          bool ampouleFind = false; // Illuminating bulb found
          for (int k = 1; k < n; k++) {
            // Look at each cell around the cell until reaching the edge of the grid or encountering a wall
            if (!eastWall && ((i - k) >= 0)) {
              // Check east direction
              if (grid[i - k][j] == -3) {
                ampouleFind = true;
              }
              if (grid[i - k][j] >= -1) {
                eastWall = true;
              }
            }
            if (!northWall && ((j - k) >= 0)) {
              // Check north direction
              if (grid[i][j - k] == -3) {
                ampouleFind = true;
              }
              if (grid[i][j - k] >= -1) {
                northWall = true;
              }
            }
            if (!southWall && ((j + k) < n)) {
              // Check south direction
              if (grid[i][j + k] == -3) {
                ampouleFind = true;
              }
              if (grid[i][j + k] >= -1) {
                southWall = true;
              }
            }
            if (!westWall && ((i + k) < n)) {
              // Check west direction
              if (grid[i + k][j] == -3) {
                ampouleFind = true;
              }
              if (grid[i + k][j] >= -1) {
                westWall = true;
              }
            }
          }
          if (ampouleFind) {
            // If bulb found then false
            return false;
          }
        }
        if (grid[i][j] == -2 || grid[i][j] <= -4) {
          // White cell, we must check if it is illuminated, if it is not then no solution
          bool southWall = false; // South wall encountered
          bool northWall = false; // North wall encountered
          bool eastWall = false; // East wall encountered
          bool westWall = false; // West wall encountered
          bool ampouleFind = false; // Illuminating bulb found
          for (int k = 1; k < n; k++) {
            // Look at each cell around the cell until reaching the edge of the grid or encountering a wall
            if (!eastWall && ((i - k) >= 0)) {
              // Check east direction
              if (grid[i - k][j] == -3) {
                ampouleFind = true;
              }
              if (grid[i - k][j] >= -1) {
                eastWall = true;
              }
            }
            if (!northWall && ((j - k) >= 0)) {
              // Check north direction
              if (grid[i][j - k] == -3) {
                ampouleFind = true;
              }
              if (grid[i][j - k] >= -1) {
                northWall = true;
              }
            }
            if (!southWall && ((j + k) < n)) {
              // Check south direction
              if (grid[i][j + k] == -3) {
                ampouleFind = true;
              }
              if (grid[i][j + k] >= -1) {
                southWall = true;
              }
            }
            if (!westWall && ((i + k) < n)) {
              // Check west direction
              if (grid[i + k][j] == -3) {
                ampouleFind = true;
              }
              if (grid[i + k][j] >= -1) {
                westWall = true;
              }
            }
          }
          if (!ampouleFind) {
            // If no bulb found then false
            return false;
          }
        }
        // If the cell is -1 (wall), nothing to check
      }
    }
    return true;
  }
}

class GridWidget extends StatefulWidget {
  final Grid grid;
  const GridWidget({super.key, required this.grid});
  

  @override
  State<StatefulWidget> createState() => _GridWidget();
}

class _GridWidget extends State<GridWidget> {
  void clickDetected(int index) {
    List<List<int>> startGrid = widget.grid.startGrid;
    int ligne = index ~/ widget.grid.gridSize;
    int colonne = index % widget.grid.gridSize;
    if (startGrid[ligne][colonne] == -2 || startGrid[ligne][colonne] <= -4) {
      lampBuild.setVolume(1);
      lampBuild.setUrl('asset:lib/assets/musics/lampBuildSound.mp3');
      lampBuild.play();
      startGrid[ligne][colonne] = -3; //Poser une ampoule
      widget.grid.lights.add(Tuple2(ligne, colonne));

      //Eclairage des cases en ligne / colonne
      int x = colonne;
      while (x < widget.grid.gridSize && startGrid[ligne][x] < -1) {
        if (startGrid[ligne][x] == -2) {
          startGrid[ligne][x] = -4;
        } else if (startGrid[ligne][x] <= -4) {
          startGrid[ligne][x]--;
        }
        x++;
      }
      x = colonne;
      while (x >= 0 && startGrid[ligne][x] < -1) {
        if (startGrid[ligne][x] == -2) {
          startGrid[ligne][x] = -4;
        } else if (startGrid[ligne][x] <= -4) {
          startGrid[ligne][x]--;
        }
        x--;
      }
      int y = ligne;
      while (y < widget.grid.gridSize && startGrid[y][colonne] < -1) {
        if (startGrid[y][colonne] == -2) {
          startGrid[y][colonne] = -4;
        } else if (startGrid[y][colonne] <= -4) {
          startGrid[y][colonne]--;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 && startGrid[y][colonne] < -1) {
        if (startGrid[y][colonne] == -2) {
          startGrid[y][colonne] = -4;
        } else if (startGrid[y][colonne] <= -4) {
          startGrid[y][colonne]--;
        }
        y--;
      }

      setState(() {});
    } else if (startGrid[ligne][colonne] == -3) {
      lampBreak.setVolume(0.5);
      lampBreak.setUrl('asset:lib/assets/musics/lampBreakSound.mp3');
      lampBreak.play();

      startGrid[ligne][colonne] = -2; //Retirer une ampoule
      widget.grid.lights.remove(Tuple2(ligne, colonne));

      //Réduire l'éclairage des cases en ligne / colonne
      int autresAmpoulesAlignees = 0;
      int x = colonne;
      while (x < widget.grid.gridSize && startGrid[ligne][x] < -1) {
        if (startGrid[ligne][x] == -4) {
          startGrid[ligne][x] = -2;
        } else if (startGrid[ligne][x] < -4) {
          startGrid[ligne][x]++;
        }
        if (startGrid[ligne][x] == -3) {
          autresAmpoulesAlignees++;
        }
        x++;
      }
      x = colonne;
      while (x >= 0 && startGrid[ligne][x] < -1) {
        if (startGrid[ligne][x] == -4) {
          startGrid[ligne][x] = -2;
        } else if (startGrid[ligne][x] < -4) {
          startGrid[ligne][x]++;
        }
        if (startGrid[ligne][x] == -3) {
          autresAmpoulesAlignees++;
        }
        x--;
      }
      int y = ligne;
      while (y < widget.grid.gridSize && startGrid[y][colonne] < -1) {
        if (startGrid[y][colonne] == -4) {
          startGrid[y][colonne] = -2;
        } else if (startGrid[y][colonne] < -4) {
          startGrid[y][colonne]++;
        }
        if (startGrid[y][colonne] == -3) {
          autresAmpoulesAlignees++;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 && startGrid[y][colonne] < -1) {
        if (startGrid[y][colonne] == -4) {
          startGrid[y][colonne] = -2;
        } else if (startGrid[y][colonne] < -4) {
          startGrid[y][colonne]++;
        }
        if (startGrid[y][colonne] == -3) {
          autresAmpoulesAlignees++;
        }
        y--;
      }
      if (autresAmpoulesAlignees > 0) {
        startGrid[ligne][colonne] = -3 - autresAmpoulesAlignees;
      }

      setState(() {});
    }
    //print(widget.grid.solutionChecker(widget.grid.startGrid));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = widget.grid.gridSize;
    List<List<int>> startGrid = widget.grid.startGrid;
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
      itemCount: gridSize * gridSize,
      itemBuilder: (BuildContext context, int index) {
        int row = index ~/ gridSize;
        int col = index % gridSize;
        return GestureDetector(
          onTap: () {
            clickDetected(index);
          },
          child: GridTile(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: startGrid[row][col] == -1
                      ? Colors.black
                      : startGrid[row][col] >= 0
                          ? Colors.black
                          : startGrid[row][col] == -3
                              ? Colors.blue //Temporaire pour les ampoules
                              : startGrid[row][col] <= -4
                                  ? Colors.amber
                                  : Colors.white),
              child: Center(
                child: Text(
                  startGrid[row][col] >= 0
                      ? startGrid[row][col].toString()
                      : '',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
