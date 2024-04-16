import 'package:akari/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:akari/models/database.dart';
import 'package:just_audio/just_audio.dart';
import 'views/home.dart'; // Importation de votre fichier home.dart

DatabaseManager databaseManager = DatabaseManager();
AudioPlayer player = AudioPlayer();

void main() {
  databaseManager.initDatabase();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await player.setUrl('asset:lib/assets/musics/backgroundMusic.mp3');
    player.setVolume(backGroungMusicVol);
    player.setLoopMode(LoopMode.all);
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akari',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 192, 195, 197)),
        useMaterial3: true,
        scaffoldBackgroundColor: Color.fromARGB(255, 192, 195, 197),
      ),
      home: Home(title: "Akari"),
    );
  }
}
