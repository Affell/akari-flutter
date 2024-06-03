import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akari/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as ws;
import '../main.dart' as pref_main;

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
      default:
        print(dataJson);
    }
  }, onError: (error) {
    print('WebSocket connection error: $error');
  });
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
}

/// Handles the 'search' event.
onSearch(Map data) {
  bool success = data['success'];
  // TODO confirmation visuelle recherche de partie
}

/// Handles the 'cancelSearch' event.
cancelSearch() {
  socket.sink.add(jsonEncode({
    'name': 'cancelSearch',
    'data': {},
  }));
}

/// Handles the 'gridSubmit' event.
submitGrid(List<List<int>> grid) {
  socket.sink.add(jsonEncode({
    'name': 'gridSubmit',
    'data': {'grid': grid},
  }));
}

/// Handles the 'scoreboard' event.
onScoreboard(data) {
  int offset = data['offset'] as int;
  List<dynamic> list = data['users'] as List<dynamic>;
  List<Map<String, dynamic>> users =
      list.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  //TODO update scoreboard view
}

/// Sends a request to get the scoreboard with the specified offset.
askScoreboard(int offset) {
  socket.sink.add(jsonEncode({
    'name': 'scoreboard',
    'data': {'offset': offset},
  }));
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
}

/// The main function of the application.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  pref_main.prefs = await SharedPreferences.getInstance();
  initWebSocket();
}
