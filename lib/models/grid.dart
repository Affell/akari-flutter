import 'dart:math';

import 'package:akari/main.dart';
import 'package:akari/models/action.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/settings.dart';
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
  List<List<int>> currentGrid = [];
  List<Tuple2<int, int>> lights = [];
  List<Tuple2<int, int>> actionsPassees = [];
  List<Tuple2<int, int>> actionsFutures = [];
  List<GridAction> actions =
      []; //inutile, mais encore là car jsp comment modif la save

  Grid.createGrid(
      {required this.difficulty,
      required this.gridSize,
      required this.creationTime}) {
    generateGrid();
    initCurrentGrid();
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
      startGrid[x][y] = 5;
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
              startGrid[i][j] = -5; //Contrainte à placer
              nbContraintes++;
            }
          }
        }
      }
    }
    //Update des contraintes avec le nombre d'ampoules autour
    for (int j = 0; j < gridSize; j++) {
      for (int k = 0; k < gridSize; k++) {
        //Si on doit placer une contrainte
        if (startGrid[j][k] == -5) {
          int ampoulesNear = 0;
          int nbCasesVidesNear = 0;
          //On regarde au dessus, en dessous et sur les côtés le nombre d'ampoules et le nombre de cases vides
          if (isInGrid(k + 1, j)) {
            if (startGrid[j][k + 1] == 5) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j][k + 1] == -2) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k - 1, j)) {
            if (startGrid[j][k - 1] == 5) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j][k - 1] == -2) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k, j + 1)) {
            if (startGrid[j + 1][k] == 5) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j + 1][k] == -2) {
              nbCasesVidesNear++;
            }
          }
          if (isInGrid(k, j - 1)) {
            if (startGrid[j - 1][k] == 5) {
              ampoulesNear++;
              nbCasesVidesNear++;
            } else if (startGrid[j - 1][k] == -2) {
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
    //On remet à -2 les cases temporairement mises à 5 (les ampoules)
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (startGrid[i][j] == 5) {
          startGrid[i][j] = -2;
        }
      }
    }
  }

  /// Copy d'une grille gSource dans une grille gCible
  initCurrentGrid() {
    currentGrid = [];
    for (int i = 0; i < gridSize; i++) {
      currentGrid.add([]);
      for (int j = 0; j < gridSize; j++) {
        currentGrid[i].add(startGrid[i][j]);
      }
    }
  }

  /// Création d'une grille à partir d'une liste de lights et d'une startGrid
  gridFromLights(List<Tuple2<int, int>> lights) {
    for (int i = 0; i < lights.length; i++) {
      actionSurCase(lights[i]);
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
        if (grid[i][j] >= 0 && grid[i][j] < 5) {
          // Wall with condition
          int nb = 0; // Counter to count the number of bulbs around the cell
          // Condition to count bulbs north, south, east, west
          if (i - 1 >= 0) {
            if (grid[i - 1][j] == 5) {
              nb++;
            }
          }
          if (i + 1 < n) {
            if (grid[i + 1][j] == 5) {
              nb++;
            }
          }
          if (j - 1 >= 0) {
            if (grid[i][j - 1] == 5) {
              nb++;
            }
          }
          if (j + 1 < n) {
            if (grid[i][j + 1] == 5) {
              nb++;
            }
          }
          if (nb != grid[i][j]) {
            // If the expected number does not match the found number then return false
            //print("pas le bon nombre d'ampoules en $i $j");
            return false;
          }
        }
        if (grid[i][j] > 5) {
          //print("ampoule alignée avec une autre en $i $j");
          return false;
          /*
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
              if (grid[i - k][j] == 5) {
                ampouleFind = true;
              }
              if (grid[i - k][j] >= -1) {
                eastWall = true;
              }
            }
            if (!northWall && ((j - k) >= 0)) {
              // Check north direction
              if (grid[i][j - k] == 5) {
                ampouleFind = true;
              }
              if (grid[i][j - k] >= -1) {
                northWall = true;
              }
            }
            if (!southWall && ((j + k) < n)) {
              // Check south direction
              if (grid[i][j + k] == 5) {
                ampouleFind = true;
              }
              if (grid[i][j + k] >= -1) {
                southWall = true;
              }
            }
            if (!westWall && ((i + k) < n)) {
              // Check west direction
              if (grid[i + k][j] == 5) {
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
          */
        }

        /*
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
              if (grid[i - k][j] == 5) {
                ampouleFind = true;
              }
              if (grid[i - k][j] >= -1) {
                eastWall = true;
              }
            }
            if (!northWall && ((j - k) >= 0)) {
              // Check north direction
              if (grid[i][j - k] == 5) {
                ampouleFind = true;
              }
              if (grid[i][j - k] >= -1) {
                northWall = true;
              }
            }
            if (!southWall && ((j + k) < n)) {
              // Check south direction
              if (grid[i][j + k] == 5) {
                ampouleFind = true;
              }
              if (grid[i][j + k] >= -1) {
                southWall = true;
              }
            }
            if (!westWall && ((i + k) < n)) {
              // Check west direction
              if (grid[i + k][j] == 5) {
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
        */
        if (grid[i][j] == -2) {
          //print("il y a une case non éclairée en $i $j");
          return false;
        }
        // If the cell is -1 (wall), nothing to check
      }
    }
    return true;
  }

  ///Effectue une action sur une case (x,y) -> pose une ampoule si c'est vide, ou retire une ampoule si il y en a une
  void actionSurCase(Tuple2<int, int> coords) {
    int ligne = coords.item1;
    int colonne = coords.item2;

    if (currentGrid[ligne][colonne] == -2 ||
        currentGrid[ligne][colonne] <= -4) {
      currentGrid[ligne][colonne] = 5;

      //Eclairage des cases en ligne / colonne
      int x = colonne;
      while (x < gridSize &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -2) {
          currentGrid[ligne][x] = -4;
        } else if (currentGrid[ligne][x] <= -4) {
          currentGrid[ligne][x]--;
        } else if (currentGrid[ligne][x] >= 5 && x != colonne) {
          currentGrid[ligne][colonne]++;
          currentGrid[ligne][x]++;
        }

        x++;
      }
      x = colonne;
      while (x >= 0 &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -2) {
          currentGrid[ligne][x] = -4;
        } else if (currentGrid[ligne][x] <= -4) {
          currentGrid[ligne][x]--;
        } else if (currentGrid[ligne][x] >= 5 && x != colonne) {
          currentGrid[ligne][colonne]++;
          currentGrid[ligne][x]++;
        }
        x--;
      }
      int y = ligne;
      while (y < gridSize &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -2) {
          currentGrid[y][colonne] = -4;
        } else if (currentGrid[y][colonne] <= -4) {
          currentGrid[y][colonne]--;
        } else if (currentGrid[y][colonne] >= 5 && y != ligne) {
          currentGrid[ligne][colonne]++;
          currentGrid[y][colonne]++;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -2) {
          currentGrid[y][colonne] = -4;
        } else if (currentGrid[y][colonne] <= -4) {
          currentGrid[y][colonne]--;
        } else if (currentGrid[y][colonne] >= 5 && y != ligne) {
          currentGrid[ligne][colonne]++;
          currentGrid[y][colonne]++;
        }
        y--;
      }
    } else if (currentGrid[ligne][colonne] >= 5) {
      currentGrid[ligne][colonne] = -2;

      //Réduire l'éclairage des cases en ligne / colonne
      int autresAmpoulesAlignees = 0;
      int x = colonne;
      while (x < gridSize &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -4) {
          currentGrid[ligne][x] = -2;
        } else if (currentGrid[ligne][x] < -4) {
          currentGrid[ligne][x]++;
        }
        if (currentGrid[ligne][x] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[ligne][x]--;
        }
        x++;
      }
      x = colonne;
      while (x >= 0 &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -4) {
          currentGrid[ligne][x] = -2;
        } else if (currentGrid[ligne][x] < -4) {
          currentGrid[ligne][x]++;
        }
        if (currentGrid[ligne][x] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[ligne][x]--;
        }
        x--;
      }
      int y = ligne;
      while (y < gridSize &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -4) {
          currentGrid[y][colonne] = -2;
        } else if (currentGrid[y][colonne] < -4) {
          currentGrid[y][colonne]++;
        }
        if (currentGrid[y][colonne] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[y][colonne]--;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -4) {
          currentGrid[y][colonne] = -2;
        } else if (currentGrid[y][colonne] < -4) {
          currentGrid[y][colonne]++;
        }
        if (currentGrid[y][colonne] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[y][colonne]--;
        }
        y--;
      }

      if (autresAmpoulesAlignees > 0) {
        currentGrid[ligne][colonne] = -3 - autresAmpoulesAlignees;
      }
    }
  }
}

class GridWidget extends StatefulWidget {
  final Grid grid;
  const GridWidget({super.key, required this.grid});

  @override
  State<StatefulWidget> createState() => _GridWidget();
}

class _GridWidget extends State<GridWidget> {
  ///Lorsqu'on clique sur une case
  void clickDetected(int index) {
    List<List<int>> currentGrid = widget.grid.currentGrid;
    int ligne = index ~/ widget.grid.gridSize;
    int colonne = index % widget.grid.gridSize;

    //Undo
    widget.grid.actionsPassees.add(Tuple2(ligne, colonne));
    if (widget.grid.actionsFutures.isNotEmpty) {
      widget.grid.actionsFutures.clear();
    }

    if (currentGrid[ligne][colonne] == -2 ||
        currentGrid[ligne][colonne] <= -4) {
      lampBuild.setVolume(soundVol);
      lampBuild.setUrl('asset:lib/assets/musics/lampBuildSound.mp3');
      lampBuild.play();

      currentGrid[ligne][colonne] = 5; //Poser une ampoule
      widget.grid.lights.add(Tuple2(ligne, colonne));

      //Eclairage des cases en ligne / colonne
      int x = colonne;
      while (x < widget.grid.gridSize &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -2) {
          currentGrid[ligne][x] = -4;
        } else if (currentGrid[ligne][x] <= -4) {
          currentGrid[ligne][x]--;
        } else if (currentGrid[ligne][x] >= 5 && x != colonne) {
          currentGrid[ligne][colonne]++;
          currentGrid[ligne][x]++;
        }
        x++;
      }
      x = colonne;
      while (x >= 0 &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -2) {
          currentGrid[ligne][x] = -4;
        } else if (currentGrid[ligne][x] <= -4) {
          currentGrid[ligne][x]--;
        } else if (currentGrid[ligne][x] >= 5 && x != colonne) {
          currentGrid[ligne][colonne]++;
          currentGrid[ligne][x]++;
        }
        x--;
      }
      int y = ligne;
      while (y < widget.grid.gridSize &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -2) {
          currentGrid[y][colonne] = -4;
        } else if (currentGrid[y][colonne] <= -4) {
          currentGrid[y][colonne]--;
        } else if (currentGrid[y][colonne] >= 5 && y != ligne) {
          currentGrid[ligne][colonne]++;
          currentGrid[y][colonne]++;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -2) {
          currentGrid[y][colonne] = -4;
        } else if (currentGrid[y][colonne] <= -4) {
          currentGrid[y][colonne]--;
        } else if (currentGrid[y][colonne] >= 5 && y != ligne) {
          currentGrid[ligne][colonne]++;
          currentGrid[y][colonne]++;
        }
        y--;
      }

      setState(() {});
    } else if (currentGrid[ligne][colonne] >= 5) {
      lampBreak.setVolume(soundVol);
      lampBreak.setUrl('asset:lib/assets/musics/lampBreakSound.mp3');
      lampBreak.play();

      //Retirer une ampoule

      currentGrid[ligne][colonne] = -2;

      widget.grid.lights.remove(Tuple2(ligne, colonne));

      //Réduire l'éclairage des cases en ligne / colonne
      int autresAmpoulesAlignees = 0;
      int x = colonne;
      while (x < widget.grid.gridSize &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -4) {
          currentGrid[ligne][x] = -2;
        } else if (currentGrid[ligne][x] < -4) {
          currentGrid[ligne][x]++;
        }
        if (currentGrid[ligne][x] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[ligne][x]--;
        }
        x++;
      }
      x = colonne;
      while (x >= 0 &&
          (currentGrid[ligne][x] < -1 || currentGrid[ligne][x] >= 5)) {
        if (currentGrid[ligne][x] == -4) {
          currentGrid[ligne][x] = -2;
        } else if (currentGrid[ligne][x] < -4) {
          currentGrid[ligne][x]++;
        }
        if (currentGrid[ligne][x] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[ligne][x]--;
        }
        x--;
      }
      int y = ligne;
      while (y < widget.grid.gridSize &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -4) {
          currentGrid[y][colonne] = -2;
        } else if (currentGrid[y][colonne] < -4) {
          currentGrid[y][colonne]++;
        }
        if (currentGrid[y][colonne] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[y][colonne]--;
        }
        y++;
      }
      y = ligne;
      while (y >= 0 &&
          (currentGrid[y][colonne] < -1 || currentGrid[y][colonne] >= 5)) {
        if (currentGrid[y][colonne] == -4) {
          currentGrid[y][colonne] = -2;
        } else if (currentGrid[y][colonne] < -4) {
          currentGrid[y][colonne]++;
        }
        if (currentGrid[y][colonne] >= 5) {
          autresAmpoulesAlignees++;
          currentGrid[y][colonne]--;
        }
        y--;
      }

      if (autresAmpoulesAlignees > 0) {
        currentGrid[ligne][colonne] = -3 - autresAmpoulesAlignees;
      }

      setState(() {});
    }
    print(
        "Grille terminée et valide : ${widget.grid.solutionChecker(widget.grid.currentGrid)}");
  }

  ///Undo <-> Ctrl+Z
  void undo() {
    if (widget.grid.actionsPassees.isNotEmpty) {
      widget.grid.actionSurCase(widget.grid.actionsPassees.last);
      widget.grid.actionsFutures.add(widget.grid.actionsPassees.last);
      widget.grid.actionsPassees.removeLast();
      setState(() {});
    }
  }

  ///Redo <-> Ctrl+Y
  void redo() {
    if (widget.grid.actionsFutures.isNotEmpty) {
      widget.grid.actionSurCase(widget.grid.actionsFutures.last);
      widget.grid.actionsPassees.add(widget.grid.actionsFutures.last);
      widget.grid.actionsFutures.removeLast();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = widget.grid.gridSize;
    List<List<int>> currentGrid = widget.grid.currentGrid;
    var currentPageIndex = 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        SizedBox(
          height: 470,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize),
            itemCount: gridSize * gridSize,
            itemBuilder: (BuildContext context, int index) {
              int row = index ~/ gridSize;
              int col = index % gridSize;

              if (currentGrid[row][col] == 5) {
                //Ampoule valide
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.lightBlue),
                      child: Center(
                        child: Image.asset("lib/assets/images/bulb.png"),
                      ),
                    ),
                  ),
                );
              } else if (currentGrid[row][col] > 5) {
                //Ampoule invalide
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: wrongLamp ? Colors.red : Colors.lightBlue,
                      ),
                      child: Center(
                        child: Image.asset("lib/assets/images/bulb.png"),
                      ),
                    ),
                  ),
                );
              } else if (currentGrid[row][col] == -1) {
                //Murs de base
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        image: const DecorationImage(
                          image: AssetImage("lib/assets/images/brick_wall.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                );
              } else if (currentGrid[row][col] >= 0) {
                //Murs avec contraintes
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        image: const DecorationImage(
                          image: AssetImage("lib/assets/images/brick_wall.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${currentGrid[row][col]}",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: (1 /
                                  9 *
                                  (340 -
                                      10 *
                                          gridSize)) //Taille des chiffres inversement proportionnelle à la taille de la grille pour Ctrl F
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              /* Débug
        else if (currentGrid[row][col] <= -4) {
          return GestureDetector(
            onTap: () {
              clickDetected(index);
            },
            child: GridTile(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: passLamp ? Colors.yellow : Colors.white,
                ),
                child: Center(
                  child: Text(
                    "${currentGrid[row][col]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
          }
        */
              else if (currentGrid[row][col] <= -4) {
                //Cases éclairées
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: passLamp ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ),
                );
              } else {
                //Cases vides
                return GestureDetector(
                  onTap: () {
                    clickDetected(index);
                  },
                  child: GridTile(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.white),
                      child: Center(
                        child: Text(
                          currentGrid[row][col] >= 0
                              ? currentGrid[row][col].toString()
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              heroTag: "Undo",
              onPressed: undo,
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "Redo",
              onPressed: redo,
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_forward),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "Validate",
              onPressed: () {}, //A faire : Validation + animation si valide
              backgroundColor: Colors.green.shade200,
              child: const Icon(Icons.check),
            ),
          ],
        ),
        const Spacer(),
        // Ajout du NavigationBar
        NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              if (index == 0 && ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Home(title: "Akari")),
                );
              } else if (index == 2 &&
                  ModalRoute.of(context)?.settings.name != '/settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              }
            });
          },
          indicatorColor: const Color.fromARGB(255, 94, 94, 93),
          selectedIndex: currentPageIndex,
          destinations: [
            NavigationDestination(
              icon: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Home(title: "Akari")),
                  );
                },
                child: const Icon(Icons.home),
              ),
              selectedIcon: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Home(title: "Akari")),
                  );
                },
                child: const Icon(Icons.home_filled),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: InkWell(
                onTap: () {},
                child: const Icon(Icons.games),
              ),
              selectedIcon: InkWell(
                onTap: () {},
                child: const Icon(Icons.games),
              ),
              label: 'Game',
            ),
            NavigationDestination(
              icon: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                },
                child: const Icon(Icons.settings),
              ),
              selectedIcon: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Settings()),
                  );
                },
                child: const Icon(Icons.settings),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ],
    );
  }
}
