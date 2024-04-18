import 'dart:convert';

import 'package:akari/models/action.dart';
import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/models/grid.dart';
import 'package:tuple/tuple.dart';

class GamesListPage extends StatefulWidget {
  final SaveMode mode;

  GamesListPage({required this.mode});

  @override
  _GamesListPageState createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late Future<List<Map<String, Object?>>> games;

  @override
  void initState() {
    super.initState();
    games = getAllGames(widget.mode);
  }

  void loadGame(Map<String, Object?> gameData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GridWidget(
        grid:Grid.loadGrid(
          creationTime: gameData['creation_time'] as int,
          time: gameData['time_spent'] as int,
          difficulty: gameData['difficulty'] as int,
          gridSize: gameData['size'] as int,
          startGrid: (jsonDecode(gameData['start_grid'] as String) as List)
        .map((item) => (item as List).map((i) => i as int).toList())
        .toList(),
          lights: (jsonDecode(gameData['lights'] as String) as List)
    .map((item) => Tuple2<int, int>((item as List)[0] as int, (item as List)[1] as int))
    .toList(),
          actions: (jsonDecode(gameData['actions'] as String) as List)
    .map((item) => GridAction.fromMap(item as Map<String, Object>)!)
    .toList(),
        
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parties en cours'),
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des parties'));
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune partie en cours'));
          }



          return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    Map<String, dynamic> gameData = snapshot.data![index];
    print(gameData);

    int creationTime = gameData['creation_time'] as int;
    int difficulty = gameData['difficulty'] as int;
    int size = gameData['size'] as int;
    int time = gameData['time_spent'] as int;

    List<List<int>> startGrid = (jsonDecode(gameData['start_grid'] as String) as List)
        .map((item) => (item as List).map((i) => i as int).toList())
        .toList();

    List<List<int>> lights = (jsonDecode(gameData['lights'] as String) as List)
        .map((item) => (item as List).map((i) => i as int).toList())
        .toList();

     List<Map<String, dynamic>> actions = (jsonDecode(gameData['actions'] as String) as List)
         .map((item) => item as Map<String, dynamic>)
         .toList();

    return ListTile(
      title: Text('Partie $creationTime'),
      subtitle: Text('Difficulté: $difficulty | Taille: $size, Temps passé: $time'),
      onTap: () {
        loadGame(gameData);
      },
    );
  },
);



        },
      ),
    );
  }
}
