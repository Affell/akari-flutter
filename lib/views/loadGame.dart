// ignore_for_file: file_names

import 'package:akari/views/game.dart';
import 'package:akari/views/history.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/leaderBoard.dart';
import 'package:akari/views/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:intl/intl.dart';

class GamesListPage extends StatefulWidget {
  final SaveMode mode;

  const GamesListPage({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late Future<List<Map<String, Object?>>> games;
  int currentPageIndex = 2;
  Key navKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    games = getAllGames(widget.mode);
  }

  void loadGame(Map<String, Object?> gameData) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Game2(
          gameData: gameData,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _confirmationSuppression(Map<String, Object?> gameData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this game?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteGame(gameData['creation_time'] as int, widget.mode);
                Navigator.of(context).pop();
                setState(() {
                  games = getAllGames(widget.mode); // Refresh the list of games
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ongoing Games'),
        ),
        body: FutureBuilder<List<Map<String, Object?>>>(
          future: games,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading games'));
            }

            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(child: Text('No games in progress'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> gameData = snapshot.data![index];

                int creationTime = gameData['creation_time'] as int;
                String dateCreation = DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(creationTime * 1000));

                String difficulty;
                switch (gameData['difficulty'] as int) {
                  case 0:
                    difficulty = "Easy";
                    break;
                  case 1:
                    difficulty = "Medium";
                    break;
                  case 2:
                    difficulty = "Hard";
                    break;
                  default:
                    difficulty = "Erreur de chargement";
                    break;
                }

                int size = gameData['size'] as int;
                int time = gameData['time_spent'] as int;

                int hours = time ~/ 3600;
                int minutes = (time % 3600) ~/ 60;
                int seconds = time % 60;

                String formattedTime = '$hours h $minutes min $seconds sec';

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      'Game: $dateCreation',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Difficulty: $difficulty'),
                          const SizedBox(height: 5),
                          Text('Size: $size'),
                          const SizedBox(height: 5),
                          Text('Time spent: $formattedTime'),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmationSuppression(gameData);
                      },
                    ),
                    onTap: () {
                      loadGame(gameData);
                    },
                  ),
                );
              },
            );
          },
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
            Icon(Icons.hourglass_bottom, size: 30, color: Colors.white),
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
                    builder: (context) =>
                        const History(mode: SaveMode.archive)),
              );
            } else if (index == 2 &&
                ModalRoute.of(context)?.settings.name != '/loadGame') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const GamesListPage(mode: SaveMode.classic)),
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
                MaterialPageRoute(builder: (context) => const Settings()),
              ).then((_) {
                setState(() {
                  currentPageIndex = 2;
                  navKey = UniqueKey();
                });
              });
            }
          },
        ),
      ),
    );
  }
}
