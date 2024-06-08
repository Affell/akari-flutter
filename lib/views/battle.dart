import 'package:akari/main.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/views/home.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/websocket.dart';
import 'package:akari/models/grid.dart';

bool isSearching = false;
bool isOnGame = false;
String resultat1v1 = "";
int eloAugmentation = 0;
int nouvelElo = 0;
bool aAbandonne = false;
bool terminee = false;
//grille temporaire car on peut pas en avoir une vide
Grid grilleMulti = Grid.createGrid(
    difficulty: 0,
    gridSize: 1,
    creationTime: DateTime.now().millisecondsSinceEpoch ~/ 1000);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akari',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 192, 195, 197)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 192, 195, 197),
      ),
      home: const Battle(title: 'Akari Battle'),
    );
  }
}

class Battle extends StatefulWidget {
  const Battle({super.key, required this.title});
  final String title;

  @override
  _BattleState createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  String _searchingText = 'Looking for an opponent';
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
          _searchingText = 'Looking for an opponent${'.' * _dotCount}';
        });
      }
    });
  }

  void _stopAnimation() {
    _timer?.cancel();
    setState(() {
      _searchingText = 'Looking for an opponent';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "lib/assets/images/backgroung_$iCase.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: getTextColorBackGroung(),
                    ),
                    onPressed: () {
                      if (isSearching) {
                        //Quitte la page --> arrêt de la recherche
                        cancelSearch();
                        _stopAnimation();
                      }
                      if (isOnGame) {
                        //Quitte la page pendant la partie --> arrêt de la partie et abandon
                        forfeit();
                        terminee = false;
                        saveGame(grilleMulti, SaveMode.archive);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  Center(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: width / 7,
                        fontWeight: FontWeight.bold,
                        color: getTextColorBackGroung(),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSearching && !isOnGame)
                        Column(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                color: getTextColorBackGroung(),
                                strokeWidth: 8,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchingText,
                              style: TextStyle(
                                fontSize: 30,
                                color: getTextColorBackGroung(),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      //Etat initial sans partie et sans recherche
                      if (!isSearching && !isOnGame)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: width * 0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: AssetImage(
                                    'lib/assets/images/background_newgame_$iCase.jpeg'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // Lancer la recherche au serveur
                                  search();
                                  _startAnimation();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                minimumSize: Size(width * 0.8, 50),
                                elevation: 10,
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Start Searching",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width / 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      //Recherche d'une partie
                      if (isSearching && !isOnGame)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: width * 0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                //Arrêter la recherche côté serveur
                                cancelSearch();
                                //isSearching = false;
                                _stopAnimation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                minimumSize: Size(width * 0.8, 50),
                                elevation: 10,
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Stop",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: width / 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Partie trouvée et en cours
                      if (isOnGame)
                        Expanded(
                          child: GridWidget(
                            isOnlineGame: true,
                            grid: grilleMulti,
                          ),
                        ),
                      if (terminee)
                        AlertDialog(
                          title: Text(resultat1v1),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("New Elo : $nouvelElo"),
                              Text("($eloAugmentation elo)"),
                              if (aAbandonne) Text("$resultat1v1 by forfeit."),
                            ],
                          ),
                          /*
                          actions: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                isOnGame = false;
                                terminee = false;
                              },
                            ),
                          ],
                          */
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
