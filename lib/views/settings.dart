import 'package:akari/main.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

double backGroungMusicVol = 0.5;
double soundVol = 1;
bool wrongLamp = true;
bool passLamp = true;

AudioPlayer volSoundTest = AudioPlayer();

double lastSoundVol = 0.0; // Variable pour suivre la dernière valeur de volume

void _playSoundIfChanged(double value) {
  int divisionsChanged = ((value - lastSoundVol).abs() * 100)
      .toInt(); // Calculer le nombre de divisions franchies

  if (divisionsChanged >= 2) {
    volSoundTest.setUrl('asset:lib/assets/musics/soundVolTest.mp3');
    volSoundTest.setVolume(soundVol);
    volSoundTest.play();
    lastSoundVol = value; // Mettre à jour la dernière valeur de volume
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
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
                  _playSoundIfChanged(
                      value); // Appeler la fonction pour jouer le son si le changement est de 4 divisions
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
