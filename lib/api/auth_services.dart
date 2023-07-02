import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static Future<http.Response> login(
      String email, String password, String tokendevice) async {
    Map data = {
      "email": email,
      "password": password,
      "tokendevice": tokendevice
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'loginpegawai');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    final sharedPref = await SharedPreferences.getInstance();
    final myamap = json.encode({
      'email': email,
      'password': password,
    });
    sharedPref.setString('authData', myamap);
    return response;
  }

  static Future<http.Response> logout() async {
    var url = Uri.parse(baseURL + 'logout');
    // var body = json.decode("");
    http.Response response = await http.post(
      url,
      headers: headers,
    );
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    localStorage.remove('token');
    localStorage.remove('expired_at');

    print(response.body);
    return response;
  }

  autoLogin() async {
    var prefs = await SharedPreferences.getInstance();

    var _email = prefs.getString('email');
    //print("Autologin: "+_uid);
    return _email.toString();
  }

  static Future<http.Response> absen(String picture) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("token").toString();
    // print(picture);
    Map data = {
      "selfie_masuk": picture,
    };
    var body = json.encode(data);
    var url = Uri.parse(baseURL + 'absenmasuk');
    http.Response response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${token}",
        "Content-Type": "application/json"
      },
      body: body,
    );
    // print(headers);
    // final sharedPref = await SharedPreferences.getInstance();
    // final myamap = json.encode({
    //   'selfie_masuk': picture,
    // });
    // sharedPref.setString('authData', myamap);

    // print(response.body);
    return response;
  }
}
