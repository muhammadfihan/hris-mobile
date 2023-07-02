import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/dashboard.dart';
import 'package:hris_apps/view/home.dart';
import 'package:hris_apps/view/login.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAuth = false;

  startSplashScreen() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      isAuth = false;
    }
    if (token != null) {
      String datetime =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString();
      var expired = await localStorage
          .getString('expired_at')
          .toString()
          .replaceAll('"', '');
      DateTime sekarang = DateTime.parse(datetime.toString());
      DateTime habis = DateTime.parse(expired.toString());
      var token =
          await localStorage.getString("token").toString().replaceAll('"', '');

      final response = await http.get(Uri.parse(baseURL + 'getakun'), headers: {
        'Content-Type': 'application/json; Charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      var user = json.decode(response.body);
      if (sekarang.isAfter(habis) || user['message'] == "Unauthenticated.") {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('user');
        localStorage.remove('token');
        localStorage.remove('expired_at');
        isAuth = false;
      } else {
        isAuth = true;
      }
      // int habis = DateTime.parse(expired).microsecondsSinceEpoch;
      // int sekarang = DateTime.parse(datetime).microsecondsSinceEpoch;
      // if (token != null && sekarang < habis) {
      // setState(() {
      //   isAuth = true;
      // });
      // }
    }

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (isAuth) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainHome()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.8, 1),
          colors: <Color>[
            Color(0xff5e72e4),
            Color(0xff825ee4),
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'HRIS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
        ],
      ),
    );
  }
}
