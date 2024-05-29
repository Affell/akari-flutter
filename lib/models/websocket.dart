import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akari/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as ws;
import 'api.dart';
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
        onSearch();
        break;
      case 'scoreboard':
        onScoreboard();
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

/// Handles the 'search' event.
onSearch() {
  socket.sink.add(jsonEncode({
    'name': 'search',
    'data': {},
  }));
}

/// Handles the 'cancelSearch' event.
onCancelSearch() {
  socket.sink.add(jsonEncode({
    'name': 'cancelSearch',
    'data': {},
  }));
}

/// Handles the 'gridSubmit' event.
onGridSubmit(List<List<int>> grid) {
  socket.sink.add(jsonEncode({
    'name': 'gridSubmit',
    'data': grid,
  }));
}

/// Handles the 'scoreboard' event.
onScoreboard() {
  //TODO update scoreboard view
}

/// Sends a request to get the scoreboard with the specified offset.
askScoreboard(int offset) {
  socket.sink.add(jsonEncode({
    'name': 'scoreboard',
    'data': offset,
  }));
}

/// Sends a search request.
search() {
  socket.sink.add(jsonEncode({
    'name': 'search',
    'data': {},
  }));
}

/// The main function of the application.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  pref_main.prefs = await SharedPreferences.getInstance();
  await login('rubaine', 'NKr{4;_N7,BuaYWeXS.Hq})-#I-Tsb}y;ub%^#5Nawf3NX');
  initWebSocket();
}
