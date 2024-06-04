import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

/*
_saveData() async {
  await _prefs.setString('username', username);
  await _prefs.setString('password', password);
}
*/

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<Account> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // TODO : Conserver les infos lors de la fermeture si la connexion a réussie
                //_saveData();
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Username :",
                ),
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                ),
                const Text(
                  "Password :",
                ),
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Rendre le fond du bouton transparent
                    padding: EdgeInsets.zero, // Supprimer le padding par défaut
                    minimumSize: const Size(100, 50),
                  ),
                  onPressed: () {
                    //TODO : Effectuer la connexion
                  },
                  child: const Text("Connexion"),
                )
              ],
            ),
          )),
    );
  }
}
