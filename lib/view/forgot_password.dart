import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/otp.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'create_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var email = TextEditingController();
  Future<bool> _onWillPop() async {
    return (await Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext ctx) => LoginScreen()))) ??
        false;
  }

  sendemail() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mohon Tunggu',
      text: 'Sedang Proses',
    );
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request =
        http.MultipartRequest('POST', Uri.parse(baseURL + 'password/email'));
    request.headers.addAll(headers);
    request.fields['email'] = email.text;

    var res = await request.send();
    var responseBytes = await res.stream.toBytes();
    var responseString = utf8.decode(responseBytes);

    final dataDecode = jsonDecode(responseString);
    if (res.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => OTP(
                    email: email.text,
                  )));
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        confirmBtnColor: AppColor.success,
        title: 'Berhasil',
        text: 'Kode OTP Anda telah terkirim ke email anda',
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.danger,
        title: 'Gagal',
        text: 'Email Tidak Terdaftar',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: false,
            elevation: 0,
            titleSpacing: 0.0,
            leading: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext ctx) => LoginScreen()));
                  },
                  child: const Icon(
                    FeatherIcons.arrowLeft,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
            title: Transform(
              transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/lupa.png",
                    height: 270,
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Reset password",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColor.primary),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Anda dapat menggunakan fitur ini jika anda lupa dengan password anda atau anda baru saja dibuatkan akun oleh perusahaan anda",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF5F72E4),
                        ),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7))),
                    child: TextFormField(
                      controller: email,
                      onSaved: (String? val) {
                        email.text = val!;
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukan Email Anda',
                          contentPadding: EdgeInsets.all(10)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await sendemail();
                    },
                    color: Color(0xFFFB6340),
                    height: 20,
                    minWidth: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Text(
                      "Send OTP Email",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
