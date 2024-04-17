import 'package:akari/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:akari/models/database.dart';
import 'package:just_audio/just_audio.dart';
import 'views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';



DatabaseManager databaseManager = DatabaseManager();
AudioPlayer player = AudioPlayer();
late SharedPreferences _prefs;
late double backGroungMusicVol;
late double soundVol;
late bool wrongLamp;
late bool passLamp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _prefs = await SharedPreferences.getInstance();
  await _loadData();

  databaseManager.initDatabase();
  runApp(const MainApp());
}

_loadData() {
  backGroungMusicVol = _prefs.getDouble('backGroungMusicVol') ?? 0.5;
  soundVol = _prefs.getDouble('soundVol') ?? 1;
  wrongLamp = _prefs.getBool('wrongLamp') ?? true;
  passLamp = _prefs.getBool('passLamp') ?? true;
}



class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainAppState();
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 192, 195, 197)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 192, 195, 197),
      ),
      home: const Home(title: "Akari"),
    );
  }
}