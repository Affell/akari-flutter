import 'dart:ui';

import 'package:akari/utils/save.dart';
import 'package:akari/views/game.dart';
import 'package:akari/views/history.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/leaderBoard.dart';
import 'package:akari/views/settings.dart';
import 'package:akari/views/battle.dart';
import 'package:akari/views/tuto.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:akari/models/websocket.dart';

Map<int, String> sizeMap = {
  0: '7x7',
  1: '10x10',
  2: '14x14',
  3: '25x25',
};

Map<int, String> difficultyMap = {
  0: 'Easy',
  1: 'Medium',
  2: 'Hard',
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'New Game',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 192, 195, 197),
          scaffoldBackgroundColor: const Color.fromARGB(255, 192, 195, 197),
        ),
        home: const NewGame(),
      ),
    );
  }
}

class NewGame extends StatefulWidget {
  const NewGame({super.key});

  @override
  State<StatefulWidget> createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGame> {
  double _sizeIndex = 1.0; // Corresponds to 10x10
  double _difficultyIndex = 1.0; // Corresponds to Medium
  int currentPageIndex = 2;
  Key navKey = UniqueKey();

  void _launchGame() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Game(
          size: [7, 10, 14, 25][_sizeIndex.toInt()],
          difficulty: _difficultyIndex.toInt(),
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _launchBattle() {
    //TODO init websocket
    initWebSocket();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Battle(title: 'Akari Battle'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Game',
          style: TextStyle(fontSize: width / 10, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.help_outline,
              size: width / 10,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Tuto(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Singleplayer',
              style: TextStyle(
                fontSize: width / 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SIZE',
                  style: TextStyle(
                    fontSize: width / 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${sizeMap[_sizeIndex.toInt()]}'),
              ],
            ),
            Slider(
              value: _sizeIndex,
              min: 0,
              max: 3,
              divisions: 3,
              onChanged: (value) {
                setState(() {
                  _sizeIndex = value;
                });
              },
              label: '${sizeMap[_sizeIndex.toInt()]}',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DIFFICULTY',
                  style: TextStyle(
                    fontSize: width / 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${difficultyMap[_difficultyIndex.toInt()]}'),
              ],
            ),
            Slider(
              value: _difficultyIndex,
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) {
                setState(() {
                  _difficultyIndex = value;
                });
              },
              label: '${difficultyMap[_difficultyIndex.toInt()]}',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchGame,
              child: const Text('Launch Game'),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.black,
            ),
            const SizedBox(height: 15),
            Text(
              'Multiplayer',
              style: TextStyle(
                fontSize: width / 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _launchBattle,
              child: const Text('Launch Battle'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: navKey,
        animationDuration: Duration.zero,
        index: currentPageIndex,
        color: const Color.fromARGB(255, 55, 55, 55),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        buttonBackgroundColor: const Color.fromARGB(255, 55, 55, 55),
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.library_add, size: 30, color: Colors.white),
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
              ModalRoute.of(context)?.settings.name != '/newGame') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NewGame()),
            );
          } else if (index == 3 &&
              ModalRoute.of(context)?.settings.name != '/leaderBoard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const LeaderBoard(mode: SaveMode.archive)),
            );
          } else if (index == 4 &&
              ModalRoute.of(context)?.settings.name != '/settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            ).then((_) {
              currentPageIndex = 2;
              navKey = UniqueKey();
            });
          }
        },
      ),
    );
  }
}
