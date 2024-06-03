import 'package:akari/main.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/views/history.dart';
import 'package:akari/views/leaderBoard.dart';
import 'package:akari/views/loadGame.dart';
import 'package:akari/views/newGame.dart';
import 'package:akari/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

final List<Color> colorsBackGroung = [
  Colors.white,
  Colors.white,
  Colors.white,
];

final List<Color> colorsButtonContinu = [
  Colors.white,
  Colors.white,
  Colors.white,
];

final List<Color> colorsButtonNewGame = [
  Colors.white,
  Colors.white,
  Colors.white,
];

Color getTextColorBackGroung() {
  return colorsBackGroung[iCase];
}

Color getTextColorButtonNewGame() {
  return colorsButtonNewGame[iCase];
}

Color getTextColorButtonContinu() {
  return colorsButtonContinu[iCase];
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;
  Key navKey = UniqueKey(); 
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            "lib/assets/images/backgroung_$iCase.jpeg",
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: width / 3,
                  fontWeight: FontWeight.bold,
                  color: getTextColorBackGroung(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: Center(
                  child: Image.asset("lib/assets/images/bulbHome2.png",
                      width: width * 0.8, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: width * 0.1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorsBackGroung[iCase], width: 2),
                  image: DecorationImage(
                    image: AssetImage(
                        'lib/assets/images/background_continu_$iCase.jpeg'), // Chemin vers votre image
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(
                      8.0), // Optionnel: pour arrondir les bords
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GamesListPage(
                          mode: SaveMode.classic,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .transparent, // Rendre le fond du bouton transparent
                    minimumSize: Size(width * 0.8, 50),
                    elevation: 10,
                    padding: EdgeInsets.zero, // Supprimer le padding par défaut
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Continue",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 8,
                                  color: getTextColorButtonContinu(),
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
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: width * 0.1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorsBackGroung[iCase], width: 2),
                  image: DecorationImage(
                    image: AssetImage(
                        'lib/assets/images/background_newgame_$iCase.jpeg'), // Chemin vers votre image
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(
                      8.0), // Optionnel: pour arrondir les bords
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewGame(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .transparent, // Rendre le fond du bouton transparent
                    minimumSize: Size(width * 0.8, 50),
                    elevation: 10,
                    padding: EdgeInsets.zero, // Supprimer le padding par défaut
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New Game",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 8,
                                  color: getTextColorButtonNewGame(),
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
          ],
        ),
      ]),
      bottomNavigationBar: CurvedNavigationBar(
        key: navKey,
        index: currentPageIndex,
        color: const Color.fromARGB(255, 55, 55, 55),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        buttonBackgroundColor: const Color.fromARGB(255, 55, 55, 55),
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.leaderboard_rounded, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });

          // Navigation logic
          if (index == 0 && ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Home(title: "Akari")),
            );
          } else if (index == 1 &&
              ModalRoute.of(context)?.settings.name != '/historical') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const History(mode: SaveMode.archive)),
            );
          } else if (index == 2 &&
              ModalRoute.of(context)?.settings.name != '/leaderBoard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const LeaderBoard(mode: SaveMode.archive)),
            );
          } else if (index == 3 &&
              ModalRoute.of(context)?.settings.name != '/settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            ).then((_) {
                setState(() {
                  currentPageIndex=0;
                  navKey = UniqueKey();
                });
              });
          }
        },
      ),
    ));
  }
}
