import 'package:akari/main.dart';
import 'package:akari/models/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

_saveData() async {
  await _prefs.setString('username', username);
  await _prefs.setString('INSAkari-Connect-Token', token);
}

_initPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<Account> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _signupEmailController;
  late TextEditingController _signupUsernameController;
  late TextEditingController _signupPasswordController;
  late TextEditingController _signupConfirmPasswordController;

  @override
  void initState() {
    super.initState();
    _initPrefs().then((_) {
      setState(() {
        _usernameController =
            TextEditingController(text: _prefs.getString('username') ?? '');
        _passwordController =
            TextEditingController(text: _prefs.getString('password') ?? '');
        _signupEmailController = TextEditingController();
        _signupUsernameController = TextEditingController();
        _signupPasswordController = TextEditingController();
        _signupConfirmPasswordController = TextEditingController();
      });
    });
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
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Username:",
                ),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Password:",
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(100, 50),
                  ),
                  onPressed: () async {
                    username = _usernameController.text;
                    String password = _passwordController.text;
                    String? resultatConnexion = await login(username, password);
                    if (resultatConnexion == null) {
                      afficherPopup(context, "Login Successful",
                          "You are now connected.\nYou now have access to the battle mode.");
                    } else {
                      afficherPopup(context, "Login Failed", resultatConnexion);
                    }
                  },
                  child: const Text("Login"),
                ),
                const Divider(
                  color: Colors.black,
                  height: 40,
                  thickness: 1,
                ),
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Email:",
                ),
                TextField(
                  controller: _signupEmailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Username:",
                ),
                TextField(
                  controller: _signupUsernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Password:",
                ),
                TextField(
                  controller: _signupPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Confirm Password:",
                ),
                TextField(
                  controller: _signupConfirmPasswordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm your password',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(100, 50),
                  ),
                  onPressed: () async {
                    String email = _signupEmailController.text;
                    String username = _signupUsernameController.text;
                    String password = _signupPasswordController.text;
                    String confirmPassword =
                        _signupConfirmPasswordController.text;
                    if (email != "" &&
                        username != "" &&
                        password != "" &&
                        confirmPassword != "") {
                      if (password != confirmPassword) {
                        afficherPopup(context, "Sign Up Failed",
                            "Passwords do not match.");
                      } else {
                        String? resultatInscription =
                            await signUp(username, email, password);

                        // TODO : Vérif que l'inscription se fait correctement pour afficher résultat
                        if (resultatInscription == null) {
                          afficherPopup(context, "Registration Successful",
                              "You are now registered.");
                        } else {
                          afficherPopup(context, "Registration Failed",
                              resultatInscription);
                        }
                      }
                    } else {
                      afficherPopup(context, "Sign Up Failed",
                          "One or more fields are empty.");
                    }
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void afficherPopup(BuildContext context, String titre, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titre),
        content: Text(message),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
