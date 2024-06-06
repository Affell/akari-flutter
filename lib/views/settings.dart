import 'package:akari/main.dart';
import 'package:akari/views/game.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

AudioPlayer volSoundTest = AudioPlayer();
double lastSoundVol = 0.0;
late SharedPreferences _prefs;
int nbTheme = 3;

void _playSoundIfChanged(double value) {
  int divisionsChanged = ((value - lastSoundVol).abs() * 100).toInt();

  if (divisionsChanged >= 2) {
    volSoundTest.setUrl('asset:lib/assets/musics/soundVolTest.mp3');
    volSoundTest.setVolume(value);
    volSoundTest.play();
    lastSoundVol = value;
  }
}

_initPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}

_saveData() async {
  await _prefs.setDouble('backGroungMusicVol', backGroungMusicVol);
  await _prefs.setDouble('soundVol', soundVol);
  await _prefs.setBool('wrongLamp', wrongLamp);
  await _prefs.setBool('passLamp', passLamp);
  await _prefs.setInt('iBulb', iBulb);
  await _prefs.setInt('iWall', iWall);
  await _prefs.setInt('iCase', iCase);
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  List<String> bulbImages = [];
  List<String> wallImages = [];
  List<String> caseImages = [];
  int currentPageIndex = 3;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadImagesBulb();
    _loadImagesWall();
    _loadImagesCase();
  }

  _loadImagesBulb() {
    for (int i = 0; i < nbTheme; i++) {
      String imagePath = 'lib/assets/images/bulb_$i.png';
      bulbImages.add(imagePath);
    }
  }

  _loadImagesWall() {
    for (int i = 0; i < nbTheme; i++) {
      String imagePath = 'lib/assets/images/wall_$i.png';
      wallImages.add(imagePath);
    }
  }

  _loadImagesCase() {
    for (int i = 0; i < nbTheme; i++) {
      String imagePath = 'lib/assets/images/case_$i.png';
      caseImages.add(imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saveData();
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.close),
                        SizedBox(width: 16.0),
                        Text('Show Incompatible Lamps:'),
                      ],
                    ),
                    Switch(
                      value: wrongLamp,
                      onChanged: (value) {
                        setState(() {
                          wrongLamp = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.light_mode),
                        SizedBox(width: 16.0),
                        Text('Show Light Pass'),
                      ],
                    ),
                    Switch(
                      value: passLamp,
                      onChanged: (value) {
                        setState(() {
                          passLamp = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Volume Background Music:'),
                Slider(
                  value: backGroungMusicVol,
                  min: 0,
                  max: 0.5,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      backGroungMusicVol = value;
                      player.setVolume(backGroungMusicVol);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                const Text('Volume Sounds:'),
                Slider(
                  value: soundVol,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      soundVol = value;
                      _playSoundIfChanged(value);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                const Text('Available bulbs:'),
                Container(
                  height: 50,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: bulbImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            iBulb = index;
                            _saveData();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: iBulb == index
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3.0,
                              ),
                            ),
                            child: Image.asset(
                              bulbImages[index],
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Available walls:'),
                Container(
                  height: 50,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: wallImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            iWall = index;
                            _saveData();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: iWall == index
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3.0,
                              ),
                            ),
                            child: Image.asset(
                              wallImages[index],
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Available tile backgrounds:'),
                Container(
                  height: 50,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: caseImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            iCase = index;
                            updateBackgroundKey();
                            _saveData();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: iCase == index
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3.0,
                              ),
                            ),
                            child: Image.asset(
                              caseImages[index],
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
