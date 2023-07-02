import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/presensi/masuk.dart';
import 'package:hris_apps/view/presensi/presensi.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hris_apps/style/color.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewPage extends StatefulWidget {
  PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late Position position;

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457
  }

  Future getAbsen() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'getabsenmobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var user = json.decode(response.body);
    if (user['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ));
    } else {
      return user;
    }
  }

  void gps() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void ambil() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mohon Tunggu',
      text: 'Sedang Proses',
    );
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse(baseURL + 'absenmasukmobile'));

      request.headers.addAll(headers);
      request.fields['latmasuk'] = position.latitude.toString();
      request.fields['lonmasuk'] = position.longitude.toString();

      var pic = await http.MultipartFile.fromPath(
          "selfie_masuk", widget.picture.path);

      request.files.add(pic);

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);

      if (res.statusCode == 200) {
        Navigator.of(context, rootNavigator: true).pop();
        if (dataDecode['status'] == 25) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            confirmBtnColor: AppColor.danger,
            title: 'Gagal',
            text: 'Maaf Anda Sedang Cuti',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop(true);
            },
          );
        }
        if (dataDecode['status'] == 13) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            confirmBtnColor: AppColor.danger,
            title: 'Gagal',
            text: 'Maaf Saat Ini Bukan Jam Kerja',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop(true);
            },
          );
        }
        if (dataDecode['status'] == 20) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            confirmBtnColor: AppColor.danger,
            title: 'Gagal',
            text: 'Maaf Anda Sedang Izin',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop(true);
            },
          );
        }
        if (dataDecode['status'] == 100) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            confirmBtnColor: AppColor.primary,
            title: 'Berhasil',
            text: 'Anda Berhasil Melakukan Presensi Masuk',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          );
        }
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  void ambilpulang() async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Mohon Tunggu',
      text: 'Sedang Proses',
    );
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse(baseURL + 'absenpulangmobile'));

      request.headers.addAll(headers);
      request.fields['latpulang'] = position.latitude.toString();
      request.fields['lonpulang'] = position.longitude.toString();

      var pic = await http.MultipartFile.fromPath(
          "selfie_pulang", widget.picture.path);

      request.files.add(pic);

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());
      if (res.statusCode == 200) {
        Navigator.of(context, rootNavigator: true).pop();
        if (dataDecode['status'] == 12) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            confirmBtnColor: AppColor.danger,
            title: 'Gagal',
            text: 'Belum Saatnya Pulang',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          );
        }
        if (dataDecode['status'] == 100) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            confirmBtnColor: AppColor.primary,
            title: 'Berhasil',
            text: 'Anda Telah Melakukan Presensi Pulang',
            onConfirmBtnTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          );
        }
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceRatio = 4 / 3;
    getLocation();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF5F72E4),
        ),
        centerTitle: false,
        leadingWidth: 22,
        title: Text(
          'Presensi',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.camera_alt_rounded,
            ),
            tooltip: 'Comment Icon',
            color: Color(0xFF5F72E4),
            onPressed: () async {
              await availableCameras()
                  .then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CameraPage(
                          cameras: value,
                        ),
                      )));
            },
          ), //IconButton
        ], //<Wid //<Widget>[]
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height / 20),
          Text(
            'Preview Foto Presensi',
            style: TextStyle(
              fontSize: 18,
              color: AppColor.darkgrey,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 15),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 58),
            child: Transform.scale(
              scale: deviceRatio,
              child: Container(
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(widget.picture.path),
                      fit: BoxFit.cover,
                      width: 640,
                      height: 480,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 15),
          // Text(picture.name)
          FutureBuilder(
              future: getAbsen(),
              builder: (context, snaphsot) {
                if (snaphsot.data == null) {
                  return Text('');
                } else {
                  return Container(
                      margin: EdgeInsets.only(left: 18, right: 18),
                      child: Column(
                        children: [
                          if (snaphsot.data['data']['jam_masuk'] != null) ...[
                            MaterialButton(
                              onPressed: () async {
                                ambilpulang();
                              },
                              color: AppColor.warning,
                              height: 20,
                              minWidth: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Presensi Pulang",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ] else ...[
                            MaterialButton(
                              onPressed: () async {
                                ambil();
                              },
                              color: AppColor.warning,
                              height: 20,
                              minWidth:
                                  MediaQuery.of(context).size.width / 1.35,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                "Presensi Masuk",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ]
                        ],
                      ));
                }
              }),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Jika dirasa pengambilan gambar kurang sesuai, anda bisa menekan icon kamera di pojok kanan atas untuk melakukan pengambilan gambar ulang.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ]),
      ),
    );
  }
}
