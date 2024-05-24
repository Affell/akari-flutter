import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

late SharedPreferences _prefs;

Future<String?> login(String username, String password) async {
  String url = "$baseUrl/auth/login";
  Map data = {
    'username': '$username',
    'password': '$password',
  };

  http.Response res =
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

  Map dataJson = jsonDecode(res.body) as Map;

  if (res.statusCode != 200) {
    return dataJson['message'];
  } else {
    await _prefs.setString('INSAkari-Connect-Token', dataJson['token']);
    await _prefs.setString('username', dataJson['user']['username']);
    await _prefs.setString('email', dataJson['user']['email']);
    return null;
  }
}

Future<bool> checkToken() async {
  final String? token = _prefs.getString('INSAkari-Connect-Token');
  print(token);
  String url = "$baseUrl/auth/login";
  Map data = {
    'token': '$token',
  };

  http.Response res =
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 200) {
    return false;
  }
  await _prefs.setString('username', dataJson['user']['username']);
  await _prefs.setString('email', dataJson['user']['email']);
  return true;
}

Future<String?> signUp(String username, String email, String password) async {
  String url = "$baseUrl/auth/signup";
  Map data = {
    'username': '$username',
    'email': '$email',
    'password': '$password',
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 201) {
    return dataJson['message'];
  }
  return null;
}
