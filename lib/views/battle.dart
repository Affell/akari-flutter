import 'package:flutter/material.dart';
import 'dart:async';

class Battle extends StatefulWidget {
  const Battle({Key? key}) : super(key: key);

  @override
  _BattleState createState() => _BattleState();
}

class _BattleState extends State<Battle> {
  String _searchingText = 'Recherche d\'adversaire';
  int _dotCount = 0;
  late Timer _timer;
  bool _isSearching = false;

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
        _searchingText = 'Recherche d\'adversaire' + '.' * _dotCount;
      });
    });
  }

  void _stopAnimation() {
    _timer.cancel();
    setState(() {
      _isSearching = false;
      _searchingText = 'Recherche d\'adversaire';
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle 1v1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSearching)
              Text(
                _searchingText,
                style: const TextStyle(fontSize: 24),
              ),
            const SizedBox(height: 20),
            if (!_isSearching)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                    _startAnimation();
                  });
                },
                child: const Text('Lancer la recherche'),
              ),
            if (_isSearching)
              ElevatedButton(
                onPressed: _stopAnimation,
                child: const Text('Arrêter'),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Battle(),
  ));
}
