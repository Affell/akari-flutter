import 'package:flutter/material.dart';
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
    headers['INSAkari-Connect-Token'] = dataJson['token'];
    await _prefs.setString('INSAkari-Connect-Token', dataJson['token']);
    await _prefs.setString('username', dataJson['user']['username']);
    await _prefs.setString('email', dataJson['user']['email']);
    return null;
  }
}

Future<bool> checkToken() async {
  final String? token = _prefs.getString('INSAkari-Connect-Token');
  String url = "$baseUrl/auth/login";
  Map data = {
    'token': '$token',
  };

  http.Response res =
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 200) {
    headers['INSAkari-Connect-Token'] = '';
    await _prefs.remove('username');
    await _prefs.remove('email');
    await _prefs.remove('INSAkari-Connect-Token');
    return false;
  }
  headers['INSAkari-Connect-Token'] = dataJson['token'];
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

Future<String?> updateUserUsername(String username) async {
  String url = '$baseUrl/auth/user';
  Map data = {
    'username': '$username',
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 200) {
    return dataJson['message'];
  }
  await _prefs.setString('username', username);
  return null;
}

Future<String?> updateUserEmail(String email) async {
  String url = '$baseUrl/auth/user';
  Map data = {
    'email': '$email',
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 200) {
    return dataJson['message'];
  }
  await _prefs.setString('email', email);
  return null;
}

Future<String?> updateUserPassword(String password) async {
  String url = '$baseUrl/auth/user';
  Map data = {
    'password': '$password',
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  Map dataJson = jsonDecode(res.body);

  if (res.statusCode != 200) {
    return dataJson['message'];
  }
  await _prefs.setString('password', password);
  return null;
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  _prefs = await SharedPreferences.getInstance();
  print(await login(
      'username', 'e}Uv.EsVq!%%6Je;f0RkveQ3-RqS{8V)ySd8Lrrc~^.x4+!ZPj'));
  print(_prefs.getString('username'));
  print(await updateUserUsername('rubaine'));
  print(_prefs.getString('username'));
}
