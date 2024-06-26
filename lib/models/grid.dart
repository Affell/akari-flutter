// ignore_for_file: prefer_interpolation_to_compose_strings, camel_case_types, constant_identifier_names

import 'dart:math';
import 'dart:async';
import 'package:akari/main.dart';
import 'package:akari/models/websocket.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/views/battle.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/newGame.dart';
import 'package:akari/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:just_audio/just_audio.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

const List<double> ratiosWallsArea = [0.2, 0.3, 0.4];
const List<double> ratiosNumberWalls = [0.6, 0.7, 0.8];

final lampBuild = AudioPlayer();
final lampBreak = AudioPlayer();

bool finish = false;

// Formatting Time in Seconds in String
String formatTime(int time) {
  int hours = time ~/ 3600;
  int minutes = (time % 3600) ~/ 60;
  int seconds = time % 60;
  String formattedTime = "";
  if (hours < 10) {
    formattedTime = "0$hours : ";
  } else {
    formattedTime = "$hours : ";
  }
  if (minutes < 10) {
    formattedTime += "0$minutes : ";
  } else {
    formattedTime += "$minutes : ";
  }
  if (seconds < 10) {
    formattedTime += "0$seconds";
  } else {
    formattedTime += "$seconds";
  }

  return formattedTime.toString();
}

enum typeGame { Solo, VS }

class Grid {
  int difficulty;
  int gridSize;
  int time;
  int creationTime;
  typeGame type = typeGame.Solo;
  List<List<int>> startGrid = [];
  List<List<int>> currentGrid = [];
  List<Tuple2<int, int>> lights = [];
  List<Tuple2<int, int>> pastActions = [];
  List<Tuple2<int, int>> futureActions = [];

//Create a game grid
  Grid.createGrid(
      {required this.difficulty,
      required this.gridSize,
      required this.creationTime,
      this.time = 0,
      this.type = typeGame.Solo}) {
    generateGrid();
    initCurrentGrid();
  }

  Grid(
      this.creationTime,
      this.time,
      this.difficulty,
      this.gridSize,
      this.startGrid,
      this.lights,
      this.pastActions,
      this.futureActions,
      this.type);

//Loading a Game Grid
  Grid.loadGrid({
    required this.creationTime,
    required this.time,
    required this.difficulty,
    required this.gridSize,
    required this.type,
    required this.startGrid,
    required this.lights,
    required this.pastActions,
    required this.futureActions,
  }) {
    initCurrentGrid();
    gridFromLights(lights);
  }

  //Check Grid Membership
  bool isInGrid(int x, int y) {
    if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) {
      return false;
    } else {
      return true;
    }
  }

// Generates a grid
  void generateGrid() {
    for (int i = 0; i < gridSize; i++) {
      List<int> startRow = [];
      for (int j = 0; j < gridSize; j++) {
        startRow.add(0);
      }
      startGrid.add(startRow);
    }
    //Calculating the number of walls to be placed
    int nbMurs = (ratiosWallsArea[difficulty] * (gridSize * gridSize)).round();

    //Wall Placement
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
    //Bulb placement
    int nbLitCases = 0;
    int nbCasesTotalExtinguished = gridSize * gridSize -
        cpt; //Number of squares to light (the whole grid - the walls)
    x = 0;
    y = 0;
    bool wallOnPath = false;
    while (nbLitCases < nbCasesTotalExtinguished) {
      //Placement of light bulbs
      do {
        x = rand.nextInt(gridSize);
        y = rand.nextInt(gridSize);
      } while (startGrid[x][y] != 0);
      startGrid[x][y] = 5;
      nbCasesTotalExtinguished--; //One less box to light up because a light bulb is placed in it
      //Updating the number of illuminated boxes
      wallOnPath = false;
      //Column Down
      for (int j = x + 1; j < gridSize && !wallOnPath; ++j) {
        if (startGrid[j][y] == -1) {
          wallOnPath = true;
        }
        if (wallOnPath == false && startGrid[j][y] == 0) {
          startGrid[j][y] = -4;
          nbLitCases++;
        }
      }
      wallOnPath = false;
      //Column up
      for (int j = x - 1; j >= 0 && !wallOnPath; --j) {
        if (startGrid[j][y] == -1) {
          wallOnPath = true;
        }
        if (wallOnPath == false && startGrid[j][y] == 0) {
          startGrid[j][y] = -4;
          nbLitCases++;
        }
      }
      wallOnPath = false;
      //line vers la droite
      for (int j = y + 1; j < gridSize && !wallOnPath; ++j) {
        if (startGrid[x][j] == -1) {
          wallOnPath = true;
        }
        if (wallOnPath == false && startGrid[x][j] == 0) {
          startGrid[x][j] = -4;
          nbLitCases++;
        }
      }
      wallOnPath = false;
      //Line to the left
      for (int j = y - 1; j >= 0 && !wallOnPath; --j) {
        if (startGrid[x][j] == -1) {
          wallOnPath = true;
        }
        if (wallOnPath == false && startGrid[x][j] == 0) {
          startGrid[x][j] = -4;
          nbLitCases++;
        }
      }
    }
    //Temporarily set to 4 squares are set back to -2
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (startGrid[i][j] == -4) {
          startGrid[i][j] = -2;
        }
      }
    }
    //Setting up wall constraints
    int nbConstraintsTotal = (ratiosNumberWalls[difficulty] * cpt).round();
    int nbConstraints = 0;
    //Placing the Right Number of Constraints
    while (nbConstraints < nbConstraintsTotal) {
      //Browse the grid
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (startGrid[i][j] == -1) {
            //SIf we have a wall
            if (rand.nextDouble() < ratiosNumberWalls[difficulty]) {
              //Random
              startGrid[i][j] = -5; //Constraint to be placed
              nbConstraints++;
            }
          }
        }
      }
    }
    //Update constraints with the number of bulbs around
    for (int j = 0; j < gridSize; j++) {
      for (int k = 0; k < gridSize; k++) {
        //If you have to place a constraint
        if (startGrid[j][k] == -5) {
          int ampoulesNear = 0;
          int nbCasesVidesNear = 0;
          //We look at the above, below and sides for the number of bulbs and the number of empty boxes
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
          //Constraints are removed from walls that are not next to a possible location
          if (nbCasesVidesNear != 0) {
            startGrid[j][k] = ampoulesNear;
          } else {
            startGrid[j][k] = -1;
          }
        }
      }
    }
    //The squares temporarily set to 5 (the light bulbs) are reset to -2
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (startGrid[i][j] == 5) {
          startGrid[i][j] = -2;
        }
      }
    }
  }

  // Copying a gSource grid to a gCible grid
  initCurrentGrid() {
    currentGrid = [];
    for (int i = 0; i < gridSize; i++) {
      currentGrid.add([]);
      for (int j = 0; j < gridSize; j++) {
        currentGrid[i].add(startGrid[i][j]);
      }
    }
  }

  /// Creating a Grid from a List of Lights and a StartGrid
  gridFromLights(List<Tuple2<int, int>> lights) {
    for (int i = 0; i < lights.length; i++) {
      actionOnCase(lights[i]);
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
            return false;
          }
        }
        if (grid[i][j] > 5) {
          //print("ampoule alignée avec une autre en $i $j");
          return false;
        }
        if (grid[i][j] == -2) {
          //print("Case vide $i $j");
          return false;
        }
        // If the cell is -1 (wall), nothing to check
      }
    }
    return true;
  }

  ///Perform an action on a (x,y) -> place a bulb if it's empty, or remove a bulb if there is one
  void actionOnCase(Tuple2<int, int> coords) {
    int line = coords.item1;
    int column = coords.item2;

    if (currentGrid[line][column] == -2 || currentGrid[line][column] <= -4) {
      currentGrid[line][column] = 5;

      //Eclairage des cases en line / column
      int x = column;
      while (x < gridSize &&
          (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -2) {
          currentGrid[line][x] = -4;
        } else if (currentGrid[line][x] <= -4) {
          currentGrid[line][x]--;
        } else if (currentGrid[line][x] >= 5 && x != column) {
          currentGrid[line][column]++;
          currentGrid[line][x]++;
        }

        x++;
      }
      x = column;
      while (
          x >= 0 && (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -2) {
          currentGrid[line][x] = -4;
        } else if (currentGrid[line][x] <= -4) {
          currentGrid[line][x]--;
        } else if (currentGrid[line][x] >= 5 && x != column) {
          currentGrid[line][column]++;
          currentGrid[line][x]++;
        }
        x--;
      }
      int y = line;
      while (y < gridSize &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -2) {
          currentGrid[y][column] = -4;
        } else if (currentGrid[y][column] <= -4) {
          currentGrid[y][column]--;
        } else if (currentGrid[y][column] >= 5 && y != line) {
          currentGrid[line][column]++;
          currentGrid[y][column]++;
        }
        y++;
      }
      y = line;
      while (y >= 0 &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -2) {
          currentGrid[y][column] = -4;
        } else if (currentGrid[y][column] <= -4) {
          currentGrid[y][column]--;
        } else if (currentGrid[y][column] >= 5 && y != line) {
          currentGrid[line][column]++;
          currentGrid[y][column]++;
        }
        y--;
      }
    } else if (currentGrid[line][column] >= 5) {
      currentGrid[line][column] = -2;

      //Réduire l'éclairage des cases en line / column
      int otherBulbsAlines = 0;
      int x = column;
      while (x < gridSize &&
          (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -4) {
          currentGrid[line][x] = -2;
        } else if (currentGrid[line][x] < -4) {
          currentGrid[line][x]++;
        }
        if (currentGrid[line][x] >= 5) {
          otherBulbsAlines++;
          currentGrid[line][x]--;
        }
        x++;
      }
      x = column;
      while (
          x >= 0 && (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -4) {
          currentGrid[line][x] = -2;
        } else if (currentGrid[line][x] < -4) {
          currentGrid[line][x]++;
        }
        if (currentGrid[line][x] >= 5) {
          otherBulbsAlines++;
          currentGrid[line][x]--;
        }
        x--;
      }
      int y = line;
      while (y < gridSize &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -4) {
          currentGrid[y][column] = -2;
        } else if (currentGrid[y][column] < -4) {
          currentGrid[y][column]++;
        }
        if (currentGrid[y][column] >= 5) {
          otherBulbsAlines++;
          currentGrid[y][column]--;
        }
        y++;
      }
      y = line;
      while (y >= 0 &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -4) {
          currentGrid[y][column] = -2;
        } else if (currentGrid[y][column] < -4) {
          currentGrid[y][column]++;
        }
        if (currentGrid[y][column] >= 5) {
          otherBulbsAlines++;
          currentGrid[y][column]--;
        }
        y--;
      }

      if (otherBulbsAlines > 0) {
        currentGrid[line][column] = -3 - otherBulbsAlines;
      }
    }
  }
}

class GridWidget extends StatefulWidget {
  final Grid grid;
  final bool isOnlineGame;
  const GridWidget({super.key, required this.grid, required this.isOnlineGame});

  @override
  State<StatefulWidget> createState() => _GridWidget();
}

class _GridWidget extends State<GridWidget> {
  late Timer _timer;

  ///When you click on a box
  void clickDetected(int index) {
    List<List<int>> currentGrid = widget.grid.currentGrid;
    int line = index ~/ widget.grid.gridSize;
    int column = index % widget.grid.gridSize;

    if (currentGrid[line][column] == -2 || currentGrid[line][column] <= -4) {
      lampBuild.setVolume(soundVol);
      lampBuild.setUrl('asset:lib/assets/musics/lampBuildSound.mp3');
      lampBuild.play();

      //Undo
      widget.grid.pastActions.add(Tuple2(line, column));
      if (widget.grid.futureActions.isNotEmpty) {
        widget.grid.futureActions.clear();
      }

      currentGrid[line][column] = 5; //Install a light bulb
      widget.grid.lights.add(Tuple2(line, column));

      //Lighting row/column boxes
      int x = column;
      while (x < widget.grid.gridSize &&
          (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -2) {
          currentGrid[line][x] = -4;
        } else if (currentGrid[line][x] <= -4) {
          currentGrid[line][x]--;
        } else if (currentGrid[line][x] >= 5 && x != column) {
          currentGrid[line][column]++;
          currentGrid[line][x]++;
        }
        x++;
      }
      x = column;
      while (
          x >= 0 && (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -2) {
          currentGrid[line][x] = -4;
        } else if (currentGrid[line][x] <= -4) {
          currentGrid[line][x]--;
        } else if (currentGrid[line][x] >= 5 && x != column) {
          currentGrid[line][column]++;
          currentGrid[line][x]++;
        }
        x--;
      }
      int y = line;
      while (y < widget.grid.gridSize &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -2) {
          currentGrid[y][column] = -4;
        } else if (currentGrid[y][column] <= -4) {
          currentGrid[y][column]--;
        } else if (currentGrid[y][column] >= 5 && y != line) {
          currentGrid[line][column]++;
          currentGrid[y][column]++;
        }
        y++;
      }
      y = line;
      while (y >= 0 &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -2) {
          currentGrid[y][column] = -4;
        } else if (currentGrid[y][column] <= -4) {
          currentGrid[y][column]--;
        } else if (currentGrid[y][column] >= 5 && y != line) {
          currentGrid[line][column]++;
          currentGrid[y][column]++;
        }
        y--;
      }

      setState(() {});
    } else if (currentGrid[line][column] >= 5) {
      lampBreak.setVolume(soundVol);
      lampBreak.setUrl('asset:lib/assets/musics/lampBreakSound.mp3');
      lampBreak.play();

      //Removing a light bulb

      currentGrid[line][column] = -2;

      //Undo
      widget.grid.pastActions.add(Tuple2(line, column));
      if (widget.grid.futureActions.isNotEmpty) {
        widget.grid.futureActions.clear();
      }

      widget.grid.lights.remove(Tuple2(line, column));

      //Reduce the lighting of row/column boxes
      int otherBulbsAlines = 0;
      int x = column;
      while (x < widget.grid.gridSize &&
          (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -4) {
          currentGrid[line][x] = -2;
        } else if (currentGrid[line][x] < -4) {
          currentGrid[line][x]++;
        }
        if (currentGrid[line][x] >= 5) {
          otherBulbsAlines++;
          currentGrid[line][x]--;
        }
        x++;
      }
      x = column;
      while (
          x >= 0 && (currentGrid[line][x] < -1 || currentGrid[line][x] >= 5)) {
        if (currentGrid[line][x] == -4) {
          currentGrid[line][x] = -2;
        } else if (currentGrid[line][x] < -4) {
          currentGrid[line][x]++;
        }
        if (currentGrid[line][x] >= 5) {
          otherBulbsAlines++;
          currentGrid[line][x]--;
        }
        x--;
      }
      int y = line;
      while (y < widget.grid.gridSize &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -4) {
          currentGrid[y][column] = -2;
        } else if (currentGrid[y][column] < -4) {
          currentGrid[y][column]++;
        }
        if (currentGrid[y][column] >= 5) {
          otherBulbsAlines++;
          currentGrid[y][column]--;
        }
        y++;
      }
      y = line;
      while (y >= 0 &&
          (currentGrid[y][column] < -1 || currentGrid[y][column] >= 5)) {
        if (currentGrid[y][column] == -4) {
          currentGrid[y][column] = -2;
        } else if (currentGrid[y][column] < -4) {
          currentGrid[y][column]++;
        }
        if (currentGrid[y][column] >= 5) {
          otherBulbsAlines++;
          currentGrid[y][column]--;
        }
        y--;
      }

      if (otherBulbsAlines > 0) {
        currentGrid[line][column] = -3 - otherBulbsAlines;
      }

      setState(() {});
    }
  }

  ///Undo <-> Ctrl+Z
  void undo() {
    if (widget.grid.pastActions.isNotEmpty) {
      widget.grid.actionOnCase(widget.grid.pastActions.last);
      widget.grid.futureActions.add(widget.grid.pastActions.last);
      widget.grid.pastActions.removeLast();
      setState(() {});
    }
  }

  ///Redo <-> Ctrl+Y
  void redo() {
    if (widget.grid.futureActions.isNotEmpty) {
      widget.grid.actionOnCase(widget.grid.futureActions.last);
      widget.grid.pastActions.add(widget.grid.futureActions.last);
      widget.grid.futureActions.removeLast();
      setState(() {});
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      widget.grid.time++;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Key navKey = UniqueKey();
    finish = false;
    int gridSize = widget.grid.gridSize;
    List<List<int>> currentGrid = widget.grid.currentGrid;
    var currentPageIndex = 1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  Size: $gridSize * $gridSize',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  color: getTextColorBackGroung(),
                ),
              ),
              Text(
                'Difficulty: ${difficultyMap[widget.grid.difficulty]}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  color: getTextColorBackGroung(),
                ),
              ),
              SizedBox(
                child: Center(
                  child: Text(
                    '${formatTime(widget.grid.time)}  ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      color: getTextColorBackGroung(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.width,
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(5.0),
              minScale: 1,
              maxScale: 4,
              panEnabled:
                  false, //To prevent scrolling (and avoid disturbing physics)
              child: Container(
                alignment: Alignment.center,
                color: Colors
                    .black, //Black background to avoid blanks between borders
                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), //To prevent scrolling
                  shrinkWrap: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (BuildContext context, int index) {
                    int row = index ~/ gridSize;
                    int col = index % gridSize;
                    if (currentGrid[row][col] == 5) {
                      //Valide bulb
                      return GestureDetector(
                        onTap: () {
                          clickDetected(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.lightBlue),
                          child: Center(
                            child: Image.asset(
                                "lib/assets/images/bulb_$iBulb.png",
                                fit: BoxFit.cover),
                          ),
                        ),
                      );
                    } else if (currentGrid[row][col] > 5) {
                      // Invalide bulb
                      return GestureDetector(
                        onTap: () {
                          clickDetected(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: wrongLamp ? Colors.red : Colors.lightBlue,
                          ),
                          child: Center(
                            child: Image.asset(
                                "lib/assets/images/bulb_$iBulb.png"),
                          ),
                        ),
                      );
                    } else if (currentGrid[row][col] == -1) {
                      //Base Walls
                      return GestureDetector(
                        onTap: () {
                          clickDetected(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            image: DecorationImage(
                              image: AssetImage(
                                  "lib/assets/images/wall_$iWall.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    } else if (currentGrid[row][col] >= 0) {
                      //Constrained Walls
                      return GestureDetector(
                        onTap: () {
                          clickDetected(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            image: DecorationImage(
                              image: AssetImage(
                                  "lib/assets/images/wall_$iWall.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "${currentGrid[row][col]}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  fontSize: (1 /
                                      9 *
                                      (340 -
                                          10 *
                                              gridSize)) //Digit size inversely proportional to grid size for Ctrl F
                                  ),
                            ),
                          ),
                        ),
                      );
                    } else if (currentGrid[row][col] <= -4) {
                      //Illuminated Boxes
                      //Unthemed
                      if (iCase == 0) {
                        return GestureDetector(
                          onTap: () {
                            clickDetected(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: passLamp ? Colors.yellow : Colors.white,
                            ),
                          ),
                        );
                      }
                      //With theme
                      else {
                        if (!passLamp) {
                          return GestureDetector(
                            onTap: () {
                              clickDetected(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(
                                      "lib/assets/images/case_dark_$iCase.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              clickDetected(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(
                                      "lib/assets/images/case_$iCase.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      //Empty box
                      //Without theme
                      if (iCase == 0) {
                        return GestureDetector(
                          onTap: () {
                            clickDetected(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      //With theme
                      else {
                        return GestureDetector(
                          onTap: () {
                            clickDetected(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage(
                                    "lib/assets/images/case_dark_$iCase.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FloatingActionButton(
                onPressed: undo,
                backgroundColor: Colors.white,
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: redo,
                backgroundColor: Colors.white,
                child: const Icon(Icons.arrow_forward),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () {
                  _timer.cancel();
                  int i = Random().nextInt(2);
                  if (widget.grid.solutionChecker(currentGrid)) {
                    finish = true;
                    //Si on est en multi, faire submitGrid
                    if (widget.isOnlineGame) {
                      submitGrid(currentGrid);
                    }

                    int time = widget.grid.time;

                    int hours = time ~/ 3600;
                    int minutes = (time % 3600) ~/ 60;
                    int seconds = time % 60;

                    String formattedTime = '$hours h $minutes min $seconds sec';

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Congratulations!'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('lib/assets/images/congrat_$i.gif',
                                  height: 100),
                              const SizedBox(height: 16),
                              Text(
                                  'You have successfully solved this grid in : $formattedTime'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("You didn't succeed!"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('lib/assets/images/fail_$i.gif',
                                  height: 100),
                              const SizedBox(height: 16),
                              const Text("The proposed solution is incorrect."),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                _startTimer();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                backgroundColor: Colors.green.shade200,
                child: const Icon(Icons.check),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
      //Navbar
      bottomNavigationBar: CurvedNavigationBar(
        key: navKey,
        animationDuration: Duration.zero,
        index: currentPageIndex,
        color: const Color.fromARGB(255, 55, 55, 55),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color.fromARGB(255, 55, 55, 55),
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.games, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            if (index == 0 && ModalRoute.of(context)?.settings.name != '/') {
              //Partie solo
              if (widget.isOnlineGame == false) {
                if (finish == true) {
                  deleteGame(widget.grid.creationTime, SaveMode.classic);
                  saveGame(widget.grid, SaveMode.archive);
                } else {
                  saveGame(widget.grid, SaveMode.classic);
                }
              }
              //Partie multi
              else {
                //Sauvegarder dans l'historique
                saveGame(widget.grid, SaveMode.archive);
                if (finish == true) {
                  isOnGame = false;
                  terminee = false;
                } else {
                  terminee = false;
                  forfeit();
                }
              }

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
              ).then((_) {
                setState(() {
                  currentPageIndex = 1; // Index of the middle icon
                  navKey = UniqueKey();
                });
              });
            } else {
              currentPageIndex = index;
            }
          });
        },
      ),
    );
  }
}
