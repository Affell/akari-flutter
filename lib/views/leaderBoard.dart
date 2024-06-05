import 'dart:io';

import 'package:akari/views/history.dart';
import 'package:akari/views/home.dart';
import 'package:akari/views/settings.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/models/websocket.dart';

List<Map<String, dynamic>> listeScoreboard = [];

class LeaderBoard extends StatefulWidget {
  final SaveMode mode;

  const LeaderBoard({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  int currentPageIndex = 2;
  Key navKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    askScoreboard(0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('LeaderBoard'),
          ),
          body: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: listeScoreboard.length + 1,
                      itemBuilder: (context, index) {
                        if (listeScoreboard.isNotEmpty &&
                            index < listeScoreboard.length) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              Text("${listeScoreboard[index].values.last}"),
                              const Spacer(),
                              Text("${listeScoreboard[index].values.first}"),
                              const SizedBox(width: 10),
                            ],
                          );
                        } else if (listeScoreboard.isEmpty) {
                          return const Center(
                            child: Text("No player found..."),
                          );
                        }
                      },
                    ))
              ],
            ),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            key: navKey,
            index: currentPageIndex,
            color: const Color.fromARGB(255, 55, 55, 55),
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            buttonBackgroundColor: const Color.fromARGB(255, 55, 55, 55),
            animationDuration: Duration.zero,
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
                      builder: (context) =>
                          const History(mode: SaveMode.archive)),
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
                  MaterialPageRoute(builder: (context) => const Settings()),
                ).then((_) {
                  setState(() {
                    currentPageIndex = 2;
                    navKey = UniqueKey();
                  });
                });
              }
            },
          )),
    );
  }
}
