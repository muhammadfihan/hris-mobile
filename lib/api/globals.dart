import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// const String baseURL = "http://10.0.2.2:8000/api/"; //emulator localhost
// const String baseURL = "http://192.168.1.8:8000/api/";
const String baseURL = "https://prisen.online/api/";
// const String baseURL = "http://localhost:8000/api/";
const Map<String, String> headers = {"Content-Type": "application/json"};

errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Text(text),
    duration: const Duration(seconds: 1),
  ));
}