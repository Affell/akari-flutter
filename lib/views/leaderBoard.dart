import 'package:akari/views/history.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:intl/intl.dart';

// A faire quand api

class LeaderBoard extends StatefulWidget {
  final SaveMode mode;

  const LeaderBoard({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<LeaderBoard> {
  late Future<List<Map<String, Object?>>> games;
  int currentPageIndex = 2;

  @override
  void initState() {
    super.initState();
    games = getAllGames(widget.mode);
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
          title: const Text('LeaderBoard'),
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
              return const Center(child: Text('No game completed'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> gameData = snapshot.data![index];

                int creationTime = gameData['creation_time'] as int;
                String dateCreation = DateFormat('dd-MM-yyyy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(creationTime * 1000));

                int difficulty = gameData['difficulty'] as int;
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
                          Text('Time Spent: $formattedTime'),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmationSuppression(gameData);
                      },
                    ),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
        index: currentPageIndex,
        color: const Color.fromARGB(255, 55, 55, 55),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        buttonBackgroundColor: Color.fromARGB(255, 55, 55, 55),
        height: 60,
        items: <Widget>[
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
              MaterialPageRoute(builder: (context) => Home(title: "Akari")),
            );
          } else if (index == 1 &&
              ModalRoute.of(context)?.settings.name != '/historical') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => History(mode: SaveMode.archive)),
            );
          } else if (index == 2 &&
              ModalRoute.of(context)?.settings.name != '/leaderBoard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LeaderBoard(mode: SaveMode.archive)),
            );
          } else if (index == 3 &&
              ModalRoute.of(context)?.settings.name != '/settings') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Settings()),
            );
          }
        },
      )
      ),
      );
  }
}
