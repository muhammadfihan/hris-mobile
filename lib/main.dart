import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/view/home.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/splash.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api/globals.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging _fcm = await FirebaseMessaging.instance;
//   final fcmToken = await FirebaseMessaging.instance.getToken();
//   print('token ${fcmToken}');
//   NotificationSettings settings = await _fcm.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   print('User granted permission: ${settings.authorizationStatus}');
//   FirebaseMessaging.onMessage.listen((RemoteMessage event) {
//     print(event.notification!.title);
//     print(event.notification!.body);
//   });
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(null, [
    // notification icon
    NotificationChannel(
      channelGroupKey: 'basic_test',
      channelKey: 'basic',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
    )
    //add more notification type with different configuration
  ]);

  //click listiner on local notification
  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {
    print(receivedNotification.payload!['title']);
    //output from local notification click.
  });

  await Firebase.initializeApp(); //initilization of Firebase app
  FirebaseMessaging.instance
      .subscribeToTopic("all"); //subscribe firebase message on topic

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);
  //background message listiner

  runApp(MyApp());
}

Future<void> firebaseBackgroundMessage(RemoteMessage message) async {
  print(message.data);
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          //with image from URL
          id: 1,
          channelKey: 'basic', //channel configuration key
          title: message.data["title"],
          body: message.data["body"],
          notificationLayout: NotificationLayout.Default,
          payload: {"name": "flutter"}));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print(message.notification!.title);
  print(message.notification!.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: CheckAuth(),
      builder: EasyLoading.init(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen(firebaseBackgroundMessage);
    _checkIfLoggedIn();
    super.initState();
  }

  Future getAkun() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response = await http.get(Uri.parse(baseURL + 'getakun'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var user = json.decode(response.body);
    if (user['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return user;
    }
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token == null) {
      setState(() {
        isAuth = false;
      });
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
        setState(() {
          isAuth = false;
        });
      } else {
        setState(() {
          isAuth = true;
        });
      }
      // int habis = DateTime.parse(expired).microsecondsSinceEpoch;
      // int sekarang = DateTime.parse(datetime).microsecondsSinceEpoch;
      // if (token != null && sekarang < habis) {
      // setState(() {
      //   isAuth = true;
      // });
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = MainHome();
    } else {
      child = SplashScreen();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }
}
