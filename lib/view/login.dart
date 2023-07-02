import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/dashboard.dart';
import 'package:hris_apps/view/home.dart';
import 'package:hris_apps/api/auth_services.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final controller = ScrollController();

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _password = '';
  String _tokendevice = '';
  bool isVisible = true;

  void gettoken() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    _tokendevice = fcmToken!;
  }

  loginPressed() async {
    if (_email.isNotEmpty && _password.isNotEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Mohon Tunggu',
        text: 'Sedang Proses',
      );
      http.Response response =
          await AuthServices.login(_email, _password, _tokendevice);
      Map responseMap = jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(_tokendevice);
        Navigator.of(context, rootNavigator: true).pop();
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', jsonEncode(responseMap['token']));
        localStorage.setString('jabatan', jsonEncode(responseMap['jabatan']));
        localStorage.setString(
            'expired_at', jsonEncode(responseMap['expired_at']));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => MainHome(),
            ));
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.success,
          title: 'Berhasil',
          text: 'Anda Berhasil Login',
        );
      }
      if (response.statusCode == 205 ||
          response.statusCode == 201 ||
          response.statusCode == 203) {
        Navigator.of(context, rootNavigator: true).pop();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnColor: AppColor.danger,
          title: 'Gagal',
          text: 'Login Gagal',
        );
      }
    } else {
      errorSnackBar(context, 'enter all required form');
    }
  }

  @override
  Widget build(BuildContext context) {
    gettoken();
    return Container(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5FC),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
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
                    child: Column(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5.3,
                      ),
                      Text(
                        'Welcome to HRIS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 3.7),
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width / 1.12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                spreadRadius: -15,
                                blurRadius: 19,
                                color: Color.fromRGBO(0, 0, 0, 1),
                              )
                            ],
                          ),
                          child: Column(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 20,
                            ),
                            Text(
                              'Login HRIS',
                              style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 18,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 23),
                              child: Column(children: [
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF5F72E4),
                                      ),
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _email = value;
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Masukan Email',
                                        contentPadding: EdgeInsets.only(
                                            left: 10, bottom: 4)),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF5F72E4),
                                      ),
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _password = value;
                                    },
                                    obscureText: isVisible,
                                    decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                            onTap: () {
                                              isVisible = !isVisible;
                                              setState(() {});
                                            },
                                            child: Icon(isVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off)),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        border: InputBorder.none,
                                        hintText: "Masukan Password",
                                        contentPadding:
                                            EdgeInsets.only(left: 10, top: 8)),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ForgotPassword(),
                                                ));
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: Size(50, 20),
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Lupa Password ?',
                                            style: TextStyle(
                                                color: AppColor.primary,
                                                fontSize: 12),
                                          )),
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 17,
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    await loginPressed();
                                  },
                                  color: Color(0xFFFB6340),
                                  height: 20,
                                  minWidth: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ]),
                            )
                          ]),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
                        ),
                        Text(
                          'HRIS Mobile APPS 2023',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // child: Scaffold(
      //   backgroundColor: Colors.white,
      //   body: SingleChildScrollView(
      //     controller: controller,
      //     child: Container(
      //       margin: EdgeInsets.only(
      //           left: 20,
      //           right: 20,
      //           top: MediaQuery.of(context).size.height / 8),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Image.asset(
      //             "assets/loginpage.png",
      //             height: 270,
      //             width: double.infinity,
      //           ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //           Text(
      //             "Login HRIS",
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 22,
      //               color: Color(0xFF5F72E4),
      //             ),
      //             textAlign: TextAlign.center,
      //           ),
      //           SizedBox(
      //             height: 30,
      //           ),
      //           Container(
      //             decoration: BoxDecoration(
      //                 border: Border.all(
      //                   color: Color(0xFF5F72E4),
      //                 ),
      //                 color: Color.fromARGB(255, 255, 255, 255),
      //                 borderRadius: const BorderRadius.all(Radius.circular(7))),
      //             child: TextFormField(
      //               onChanged: (value) {
      //                 _email = value;
      //               },
      //               decoration: InputDecoration(
      //                   border: InputBorder.none,
      //                   hintText: 'Masukan Email',
      //                   contentPadding: EdgeInsets.all(10)),
      //             ),
      //           ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //           Container(
      //             decoration: BoxDecoration(
      //                 border: Border.all(
      //                   color: Color(0xFF5F72E4),
      //                 ),
      //                 color: Color.fromARGB(255, 255, 255, 255),
      //                 borderRadius: const BorderRadius.all(Radius.circular(7))),
      //             child: TextFormField(
      //               onChanged: (value) {
      //                 _password = value;
      //               },
      //               obscureText: isVisible,
      //               decoration: InputDecoration(
      //                   suffixIcon: GestureDetector(
      //                       onTap: () {
      //                         isVisible = !isVisible;
      //                         setState(() {});
      //                       },
      //                       child: Icon(isVisible
      //                           ? Icons.visibility
      //                           : Icons.visibility_off)),
      //                   floatingLabelBehavior: FloatingLabelBehavior.always,
      //                   border: InputBorder.none,
      //                   hintText: "Masukan Password",
      //                   contentPadding: EdgeInsets.all(10)),
      //             ),
      //           ),
      //           SizedBox(
      //             height: 20,
      //           ),
      //           Container(
      //               alignment: Alignment.topRight,
      //               child: Container(
      //                 child: TextButton(
      //                     onPressed: () {
      //                       Navigator.pushReplacement(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (BuildContext context) =>
      //                                 ForgotPassword(),
      //                           ));
      //                     },
      //                     style: TextButton.styleFrom(
      //                       minimumSize: Size(50, 20),
      //                       padding: EdgeInsets.zero,
      //                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                     ),
      //                     child: Text(
      //                       'Lupa Password ?',
      //                       style: TextStyle(
      //                           color: AppColor.primary, fontSize: 14),
      //                     )),
      //               )),
      //           SizedBox(
      //             height: 28,
      //           ),
      //           MaterialButton(
      //             onPressed: () async {
      //               await loginPressed();
      //             },
      //             color: Color(0xFFFB6340),
      //             height: 20,
      //             minWidth: double.infinity,
      //             padding: const EdgeInsets.symmetric(vertical: 8),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(7.0),
      //             ),
      //             child: Text(
      //               "Login",
      //               style: TextStyle(color: Colors.white, fontSize: 18),
      //             ),
      //           ),
      //           SizedBox(
      //             height: 8,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
