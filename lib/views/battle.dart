import 'package:akari/main.dart';
import 'package:akari/views/home.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/websocket.dart';

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
      home: const Battle(),
    );
  }
}

class Battle extends StatefulWidget {
  const Battle({super.key});

  @override
  _BattleState createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  String _searchingText = 'Recherche d\'adversaire';
  int _dotCount = 0;
  late Timer _timer;
  bool _isSearching = false;

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
        _searchingText = 'Recherche d\'adversaire${'.' * _dotCount}';
      });
    });
  }

  void _stopAnimation() {
    _timer.cancel();
    setState(() {
      _isSearching = false;
      _searchingText = 'Recherche d\'adversaire';
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle 1v1'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "lib/assets/images/backgroung_$iCase.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSearching)
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
                if (!_isSearching)
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
                            // TODO : Lancer la recherche au serveur
                            //search();
                            _isSearching = true;
                            _startAnimation();
                            //while(onSearch(data))
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: Size(width * 0.8, 50),
                          elevation: 10,
                          padding: EdgeInsets.zero,
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
                                      "Lancer la recherche",
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
                if (_isSearching)
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
                          //TODO : Arrêter la recherche côté serveur
                          //cancelSearch();
                          _stopAnimation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: Size(width * 0.8, 50),
                          elevation: 10,
                          padding: EdgeInsets.zero,
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
                                      "Arrêter",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
