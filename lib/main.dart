import 'package:flutter/material.dart';
import 'package:akari/models/database.dart';
import 'package:just_audio/just_audio.dart';
import 'views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

DatabaseManager databaseManager = DatabaseManager();
AudioPlayer player = AudioPlayer();
late SharedPreferences prefs;
late double backGroungMusicVol;
late double soundVol;
late bool wrongLamp;
late bool passLamp;
late int iBulb;
late int iWall;
late int iCase;
late String token;
late String username;
late String email;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  await _loadData();

  databaseManager.initDatabase();
  runApp(const MainApp());
}

_loadData() {
  backGroungMusicVol = prefs.getDouble('backGroungMusicVol') ?? 0.5;
  soundVol = prefs.getDouble('soundVol') ?? 1;
  wrongLamp = prefs.getBool('wrongLamp') ?? true;
  passLamp = prefs.getBool('passLamp') ?? true;
  iBulb = prefs.getInt('iBulb') ?? 0;
  iWall = prefs.getInt('iWall') ?? 0;
  iCase = prefs.getInt('iCase') ?? 0;
  // Token, username, email
  token = prefs.getString('INSAkari-Connect-Token') ?? "";
  username = prefs.getString('username') ?? "";
  email = prefs.getString('email') ?? "";
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

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
    return SafeArea(
      child: MaterialApp(
        title: 'Akari',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 192, 195, 197)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromARGB(255, 192, 195, 197),
        ),
        home: const Home(title: "Akari"),
      ),
    );
  }
}
