// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'package:akari/utils/save.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akari/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as ws;
import '../main.dart' as pref_main;
import 'package:akari/views/battle.dart';
import 'package:akari/models/grid.dart';
import 'package:akari/views/leaderBoard.dart';

late ws.WebSocketChannel socket;

/// Initializes the WebSocket connection.
initWebSocket() {
  socket = ws.WebSocketChannel.connect(Uri.parse(wsUrl));
  socket.stream.listen((data) {
    Map dataJson = jsonDecode(data) as Map;
    switch (dataJson['name']) {
      case 'auth':
        onAuth();
        break;
      case 'search':
        onSearch(dataJson['data']);
        break;
      case 'scoreboard':
        onScoreboard(dataJson['data']);
        break;
      case 'launchGame':
        onLaunchGame(dataJson["data"]);
        break;
      case 'authenticated':
        onAuthenticated();
        break;
      case 'gameResult':
        onGameResult(dataJson["data"]);
        break;
      case 'close':
        socket.sink.close();
        break;
      default:
        print(dataJson);
    }
  }, onError: (error) {
    print('WebSocket connection error: $error');
  });
}

closeSocket() {
  socket.sink.close();
}

/// Handles the 'auth' event.
onAuth() {
  final token = pref_main.prefs.getString('INSAkari-Connect-Token') ?? '';
  socket.sink.add(jsonEncode({
    'name': 'auth',
    'data': {
      'token': token,
    },
  }));
}

onAuthenticated() {
  //TODO
  print("\n\nonAuthentificated\n\n");
  //askScoreboard(0);
}

/// Handles the 'search' event.
onSearch(Map data) {
  bool success = data['success'];
  isSearching = true;
  terminee = false;
  print("\n\n Recherche d'adversaire : $isSearching \n\n");
}

/// Handles the 'cancelSearch' event.
cancelSearch() {
  socket.sink.add(jsonEncode({
    'name': 'cancelSearch',
    'data': {},
  }));
  isSearching = false;
  print("\n\n Recherche d'adversaire annulée : $isSearching \n\n");
}

/// Handles the 'gridSubmit' event.
submitGrid(List<List<int>> grid) {
  socket.sink.add(jsonEncode({
    'name': 'gridSubmit',
    'data': {'grid': grid},
  }));
  print("\n\n Grille envoyée \n\n");
  saveGame(grilleMulti, SaveMode.archive);
}

/// Handles the 'scoreboard' event.
onScoreboard(data) {
  int offset = data['offset'] as int;
  List<dynamic> list = data['users'] as List<dynamic>;
  List<Map<String, dynamic>> users =
      list.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  updateListeScoreboard(users);
}

/// Sends a request to get the scoreboard with the specified offset.
askScoreboard(int offset) {
  socket.sink.add(jsonEncode({
    'name': 'scoreboard',
    'data': {'offset': offset},
  }));
  //print("\n\n Demande du scoreboard envoyée \n\n");
}

/// Sends a search request.
search() {
  socket.sink.add(jsonEncode({
    'name': 'search',
    'data': {},
  }));
}

onLaunchGame(data) {
  List<dynamic> list = data['grid'] as List<dynamic>;
  List<List<int>> grid = list
      .map<List<int>>(
          (first) => first.map<int>((second) => second as int).toList())
      .toList();
  int size = data['size'] as int;
  int difficulty = data['difficulty'] as int;
  Map<String, dynamic> opponent = data['opponent']
      as Map<String, dynamic>; // {id:1, "username": "Affell", "score": 500}
  // TODO lancer partie graphique
  isOnGame = true;
  isSearching = false;
  grilleMulti = Grid.loadGrid(
      creationTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      difficulty: difficulty,
      startGrid: grid,
      gridSize: size,
      type: typeGame.VS,
      futureActions: [],
      pastActions: [],
      lights: [],
      time: 0);
}

onGameResult(data) {
  String result = data['result'] as String;
  int newElo = data['newElo'] as int;
  int eloDelta = data['eloDelta'] as int;
  bool forfeit = data['forfeit'] as bool;

  print("Récupération des résultats");
  if (result == "win") {
    resultat1v1 = "Win";
  } else {
    resultat1v1 = "Defeat";
  }
  eloAugmentation = eloDelta;
  nouvelElo = newElo;
  aAbandonne = forfeit;
  terminee = true;
  isOnGame = false;
}

forfeit() {
  socket.sink.add(jsonEncode({
    'name': 'forfeit',
    'data': {},
  }));
  print("\n\nForfait\n\n");
  isOnGame = false;
}

/// The main function of the application.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  pref_main.prefs = await SharedPreferences.getInstance();
  initWebSocket();
}
