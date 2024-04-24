import 'package:akari/utils/save.dart';
import 'package:akari/views/history.dart';
import 'package:akari/views/leaderBoard.dart';
import 'package:akari/views/loadGame.dart';
import 'package:akari/views/newGame.dart';
import 'package:akari/views/settings.dart';
import 'package:flutter/material.dart';

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

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 192, 195, 197),
          title: Text(widget.title,
              style:
                  TextStyle(fontSize: width / 6, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
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
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamesListPage(
                        mode: SaveMode.classic,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 128, 127, 127)),
                  minimumSize: MaterialStateProperty.all(Size(width * 0.8, 50)),
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
                            Text("Continue",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width / 15,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                    Image.asset("lib/assets/images/loadGameButton.png"),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: width * 0.1),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewGame(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 128, 127, 127)),
                  minimumSize: MaterialStateProperty.all(Size(width * 0.8, 50)),
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
                            Text("New Game",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width / 15,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  if (index == 0 &&
                      ModalRoute.of(context)?.settings.name != '/') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Home(title: "Akari")),
                    );
                  } else if (index == 1 &&
                      ModalRoute.of(context)?.settings.name != '/historical') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const History(
                                mode: SaveMode.archive,
                              )),
                    );
                  } else if (index == 2 &&
                      ModalRoute.of(context)?.settings.name != '/leaderBoard') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaderBoard(
                              mode: SaveMode
                                  .archive)), // A modif quand leaderboard fait
                    );
                  } else if (index == 3 &&
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const History(
                                  mode: SaveMode.archive,
                                )),
                      );
                    },
                    child: const Icon(Icons.history),
                  ),
                  selectedIcon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const History(
                                  mode: SaveMode.archive,
                                )),
                      );
                    },
                    child: const Icon(Icons.settings),
                  ),
                  label: 'historical',
                ),
                NavigationDestination(
                  icon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeaderBoard(
                                  mode: SaveMode.archive,
                                )),
                      );
                    },
                    child: const Icon(Icons.leaderboard_rounded),
                  ),
                  selectedIcon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeaderBoard(
                                  mode: SaveMode.archive,
                                )),
                      );
                    },
                    child: const Icon(Icons.leaderboard_rounded),
                  ),
                  label: 'LeaderBoard',
                ),
                NavigationDestination(
                  icon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Settings()),
                      );
                    },
                    child: const Icon(Icons.settings),
                  ),
                  selectedIcon: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Settings()),
                      );
                    },
                    child: const Icon(Icons.settings),
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
