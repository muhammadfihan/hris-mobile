import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_apps/style/color.dart';
import 'dart:convert';

import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/otp.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({Key? key, required this.code, required this.emailreset})
      : super(key: key);

  final code;
  final emailreset;
  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  var password = TextEditingController();
  var confirmpassword = TextEditingController();
  bool isVisible = true;
  bool isVisible2 = true;

  reset() async {
    if (password.text != confirmpassword.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.danger,
        title: 'Gagal',
        text: 'Konfirmasi Password Anda Tidak Sesuai',
      );
    }
    if (password.text == confirmpassword.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Mohon Tunggu',
        text: 'Sedang Proses',
      );
      ;

      var request =
          http.MultipartRequest('POST', Uri.parse(baseURL + 'password/reset'));
      request.fields['password'] = password.text;
      request.fields['code'] = widget.code;

      var res = await request.send();

      if (res.statusCode == 200) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen()));
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.success,
          title: 'Success',
          text: 'Silahkan Login dengan password baru anda',
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/newpass.png",
                  height: 270,
                  width: double.infinity,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Buat Password Baru",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColor.primary),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Pastikan password anda mudah untuk diingat dan tetap aman",
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
                      borderRadius: const BorderRadius.all(Radius.circular(7))),
                  child: TextFormField(
                    controller: password,
                    onSaved: (String? val) {
                      password.text = val!;
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
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                        hintText: "Masukan Password",
                        contentPadding: EdgeInsets.only(top: 14, left: 10)),
                  ),
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
                      borderRadius: const BorderRadius.all(Radius.circular(7))),
                  child: TextFormField(
                    controller: confirmpassword,
                    onSaved: (String? val) {
                      confirmpassword.text = val!;
                    },
                    obscureText: isVisible2,
                    decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                            onTap: () {
                              isVisible2 = !isVisible2;
                              setState(() {});
                            },
                            child: Icon(isVisible2
                                ? Icons.visibility
                                : Icons.visibility_off)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: InputBorder.none,
                        hintText: "Konfirmasi Password Baru",
                        contentPadding: EdgeInsets.only(top: 14, left: 10)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  onPressed: () async {
                    reset();
                  },
                  color: Color(0xFFFB6340),
                  height: 20,
                  minWidth: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Text(
                    "Reset Password",
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
    );
  }
}
