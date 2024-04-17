import 'package:akari/views/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Game',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 192, 195, 197),
        scaffoldBackgroundColor: Color.fromARGB(255, 192, 195, 197),
      ),
      home: NewGame(),
    );
  }
}

class NewGame extends StatefulWidget {
  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGame> {
  double _sizeIndex = 1.0; // Corresponds to 10x10
  double _difficultyIndex = 1.0; // Corresponds to Medium

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

  void _launchGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Game(
          size: [7, 10, 14, 25][_sizeIndex.toInt()],
          difficulty: _difficultyIndex.toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchGame,
              child: Text('Launch Game'),
            ),
          ],
        ),
      ),
    );
  }
}