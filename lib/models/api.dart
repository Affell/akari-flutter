import '../config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart' as main;

Future<String?> login(String username, String password) async {
  String url = "$apiUrl/auth/login";
  Map data = {
    'username': username,
    'password': password,
  };

  http.Response res =
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

  try {
    Map dataJson = jsonDecode(res.body) as Map;

    if (res.statusCode != 200) {
      return dataJson['message'];
    } else {
      headers['INSAkari-Connect-Token'] = dataJson['token'];
      await main.prefs.setString('INSAkari-Connect-Token', dataJson['token']);
      await main.prefs.setString('username', dataJson['user']['username']);
      await main.prefs.setString('email', dataJson['user']['email']);
      return null;
    }
  } catch (e) {
    return 'Invalid response from server';
  }
}

Future<bool> checkToken() async {
  final String? token = main.prefs.getString('INSAkari-Connect-Token');
  String url = "$apiUrl/auth/login";
  Map data = {
    'token': '$token',
  };

  http.Response res =
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));

  try {
    Map dataJson = jsonDecode(res.body) as Map;

    if (res.statusCode != 200) {
      headers['INSAkari-Connect-Token'] = '';
      await main.prefs.remove('username');
      await main.prefs.remove('email');
      await main.prefs.remove('INSAkari-Connect-Token');
      return false;
    } else {
      headers['INSAkari-Connect-Token'] = dataJson['token'];
      await main.prefs.setString('username', dataJson['user']['username']);
      await main.prefs.setString('email', dataJson['user']['email']);
      return true;
    }
  } catch (e) {
    return false;
  }
}

Future<String?> signUp(String username, String email, String password) async {
  String url = "$apiUrl/auth/signup";
  Map data = {
    'username': username,
    'email': email,
    'password': password,
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  try {
    Map dataJson = jsonDecode(res.body) as Map;

    if (res.statusCode != 201) {
      return dataJson['message'];
    } else {
      headers['INSAkari-Connect-Token'] = dataJson['token'];
      await main.prefs.setString('INSAkari-Connect-Token', dataJson['token']);
      await main.prefs.setString('username', dataJson['user']['username']);
      await main.prefs.setString('email', dataJson['user']['email']);
      return null;
    }
  } catch (e) {
    return 'Invalid response from server';
  }
}

Future<String?> updateUserUsername(String username) async {
  String url = '$apiUrl/auth/user';
  Map data = {
    'username': username,
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  try {
    Map dataJson = jsonDecode(res.body) as Map;

    if (res.statusCode != 200) {
      return dataJson['message'];
    } else {
      await main.prefs.setString('username', username);
      return null;
    }
  } catch (e) {
    return 'Invalid response from server';
  }
}

Future<String?> updateUserEmail(String email) async {
  String url = '$apiUrl/auth/user';
  Map data = {
    'email': email,
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  try {
    Map dataJson = jsonDecode(res.body) as Map;

    if (res.statusCode != 200) {
      return dataJson['message'];
    } else {
      await main.prefs.setString('email', email);
      return null;
    }
  } catch (e) {
    return 'Invalid response from server';
  }
}

Future<String?> updateUserPassword(String password) async {
  String url = '$apiUrl/auth/user';
  Map data = {
    'password': password,
  };

  http.Response res = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(data),
  );

  if (res.statusCode != 200) {
    try {
      Map dataJson = jsonDecode(res.body) as Map;
      return dataJson['message'];
    } catch (e) {
      return 'Invalid response from server';
    }
  } else {
    return null;
  }
}
