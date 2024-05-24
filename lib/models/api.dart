import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

late SharedPreferences _prefs;
String token = "";

Future<http.Response> login() async {
  String url = "$baseUrl/auth/login";
  Map data = {
    'username': 'username',
    'password': 'password',
  };

  return await http.post(Uri.parse(url),
      headers: headers, body: jsonEncode(data));
}

Future<http.Response> checkToken() async {
  _prefs = await SharedPreferences.getInstance();
  final String? token = _prefs.getString('INSAkari-Connect-Token');
  String url = "$baseUrl/auth/login";
  Map data = {
    'INSAkari-Connect-Token': '$token',
  };

  return await http.post(Uri.parse(url),
      headers: headers, body: jsonEncode(data));
}
