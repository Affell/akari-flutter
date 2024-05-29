import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akari/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as ws;
import 'api.dart';
import '../main.dart' as pref_main;

late ws.WebSocketChannel socket;

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
      case 'cancelSearch':
        onCancelSearch();
        break;
      case 'gridSubmit':
        onGridSubmit(dataJson['data']);
        break;
      case 'scoreboard':
        onScoreboard(dataJson['data']);
        break;
      default:
        print(dataJson);
    }
  }, onError: (error) {
    print('WebSocket connection error: $error');
  });
}

onAuth() {
  final token = pref_main.prefs.getString('INSAkari-Connect-Token') ?? '';
  socket.sink.add(jsonEncode({
    'name': 'auth',
    'data': {
      'token': token,
    },
  }));
}

onSearch() {
  socket.sink.add(jsonEncode({
    'name': 'search',
    'data': {},
  }));
}

onCancelSearch() {
  socket.sink.add(jsonEncode({
    'name': 'cancelSearch',
    'data': {},
  }));
}

onGridSubmit(List<List<int>> grid) {
  socket.sink.add(jsonEncode({
    'name': 'gridSubmit',
    'data': grid,
  }));
}

onScoreboard(Offset int) {
  socket.sink.add(jsonEncode({
    'name': 'scoreboard',
    'data': int,
  }));
}

search() {
  socket.sink.add(jsonEncode({
    'name': 'search',
    'data': {},
  }));
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  pref_main.prefs = await SharedPreferences.getInstance();
  await login('rubaine', 'NKr{4;_N7,BuaYWeXS.Hq})-#I-Tsb}y;ub%^#5Nawf3NX');
  initWebSocket();
}
