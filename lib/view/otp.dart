import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/forgot_password.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'create_password.dart';

class OTP extends StatefulWidget {
  const OTP({Key? key, required this.email}) : super(key: key);

  final email;

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  var otpcode = TextEditingController();
  Future<bool> _onWillPop() async {
    return (await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext ctx) => ForgotPassword()))) ??
        false;
  }

  codecek() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mohon Tunggu',
      text: 'Sedang Proses',
    );
    ;

    var request = http.MultipartRequest(
        'POST', Uri.parse(baseURL + 'password/code/check'));
    request.fields['code'] = otpcode.text;

    var res = await request.send();
    if (res.statusCode == 200) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => CreatePassword(
                    code: otpcode.text,
                    emailreset: widget.email,
                  )));
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        confirmBtnColor: AppColor.success,
        title: 'Success',
        text: 'Kode OTP Valid',
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.danger,
        title: 'Success',
        text: 'Kode OTP Tidak Valid',
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
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
                            builder: (BuildContext ctx) => ForgotPassword()));
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
                    "assets/otp.png",
                    height: 270,
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Masukan Kode OTP dari Email Anda",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColor.primary),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Periksa email terbaru anda dan masukan kode yang tertera di form dibawah ini, jika tidak ada email masuk silahkan kembali ke halaman sebelumnya",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 45,
                    child: OtpTextField(
                      numberOfFields: 6,
                      borderColor: AppColor.primary,
                      fieldWidth: 40,
                      showFieldAsBox: true,
                      //runs when a code is typed in
                      onCodeChanged: (String code) {
                        //handle validation or checks here
                      },
                      //runs when every textfield is filled
                      onSubmit: (otp) {
                        setState(() {
                          otpcode.text = otp;
                        });
                      }, // end onSubmit
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      codecek();
                    },
                    color: Color(0xFFFB6340),
                    height: 20,
                    minWidth: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Text(
                      "Verifikasi OTP",
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
