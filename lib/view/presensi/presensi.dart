import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/job/history.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/presensi/detail.dart';
import 'package:hris_apps/view/presensi/masuk.dart';
import 'package:hris_apps/view/presensi/tes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:geolocator/geolocator.dart';

class Presensi extends StatefulWidget {
  const Presensi({super.key});

  @override
  State<Presensi> createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  String txtNama = "";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";

  var Bukti = TextEditingController();

  int id = 0;
  var buktiupdt = TextEditingController();

  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    getAbsen();
    //set the initial value of text field
    super.initState();
  }

  gpscek() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      } else if (permission == LocationPermission.deniedForever) {
        print("'Location permissions are permanently denied");
      } else {
        print("GPS Location service is granted");
      }
    } else {
      print("GPS Location permission granted.");
    }
  }

  checkGps() async {
    bool servicestatus = await Geolocator.isLocationServiceEnabled();
    Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: const Center(child: CircularProgressIndicator()));
    if (servicestatus) {
      await availableCameras().then((value) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CameraPage(
              cameras: value,
            ),
          )));
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.danger,
        title: 'Tidak Bisa Presensi',
        text: 'Lokasi Anda Tidak Diizinkan',
      );
    }
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
    print(user);
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

  Future getJam() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'tampiljampeg'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var absen = json.decode(response.body);

    if (absen['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return absen;
    }
  }

  Future refresh() async {
    setState(() {
      gpscek();
      getAbsen();
    });
  }

  @override
  Widget build(BuildContext context) {
    gpscek();
    getAbsen();
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
        actions: <Widget>[], //<Widget>[]
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height / 1.23,
        child: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                FutureBuilder(
                    future: getAbsen(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            margin: EdgeInsets.only(top: 250),
                            child: Center(child: CircularProgressIndicator()));
                      }
                      if (snapshot.data['status'] == 12) {
                        return Center(
                          child: Container(
                            child: Column(children: [
                              SizedBox(
                                height: 95,
                              ),
                              Image.asset(
                                "assets/waiting.png",
                                height: 320,
                                width: double.infinity,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Presensi Belum Dibuka",
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        );
                      }
                      if (snapshot.data['status'] == 15) {
                        return Center(
                          child: Container(
                            child: Column(children: [
                              SizedBox(
                                height: 95,
                              ),
                              Image.asset(
                                "assets/liburguys.png",
                                height: 320,
                                width: double.infinity,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Silahkan Menikmati Hari Libur",
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 40,
                                  left: 20,
                                  right: 20),
                              child: Row(
                                children: <Widget>[
                                  FutureBuilder(
                                    future: getAbsen(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Text(
                                          '',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF5F72E4),
                                          ),
                                        );
                                      } else {
                                        return Text(
                                          'Presensi Harian',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Spacer(),
                                  FutureBuilder(
                                    future: getAbsen(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Text(
                                          '',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF5F72E4),
                                          ),
                                        );
                                      } else {
                                        return TextButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        DetPresensi(),
                                                  ));
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(50, 20),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Detail Presensi',
                                              style: TextStyle(
                                                  color: AppColor.primary,
                                                  fontSize: 13),
                                            ));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 110,
                            ),
                            Container(
                              child: Column(
                                children: [
                                  FutureBuilder(
                                    future: getJam(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Text('');
                                      } else {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              7,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
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
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(3, 3),
                                                  spreadRadius: -4,
                                                  blurRadius: 3,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                )
                                              ],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            32,
                                                  ),
                                                  Text(
                                                    'Jam Masuk',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    '${snapshot.data['data']['jam_masuk']}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 70,
                                                margin:
                                                    EdgeInsets.only(bottom: 25),
                                                child: const VerticalDivider(
                                                  width: 65,
                                                  thickness: 2,
                                                  indent: 20,
                                                  endIndent: 0,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            32,
                                                  ),
                                                  Text(
                                                    'Jam Pulang',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    '${snapshot.data['data']['jam_pulang']}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 50,
                                  ),
                                  Center(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.51,
                                      width: MediaQuery.of(context).size.width,
                                      child: Card(
                                        margin: EdgeInsets.only(
                                            left: 17, right: 17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        color: Colors.white,
                                        elevation: 10,
                                        child: FutureBuilder(
                                          future: getAbsen(),
                                          builder: (context, snapshot) {
                                            if (snapshot.data == null) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  ListTile(
                                                    title: Text('Null',
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    subtitle: Text(
                                                      'NIP. Null',
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            15,
                                                  ),
                                                  Container(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              'Your Attendance',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  color: AppColor
                                                                      .darkgrey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                              DateFormat
                                                                      .yMMMMEEEEd()
                                                                  .format(DateTime
                                                                      .now()),
                                                              style: TextStyle(
                                                                fontSize: 20.0,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              )),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          DigitalClock(
                                                            hourMinuteDigitTextStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        52,
                                                                    color: AppColor
                                                                        .primary),
                                                            secondDigitTextStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: AppColor
                                                                        .primary),
                                                            colon: Text(
                                                              ":",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle1!
                                                                  .copyWith(
                                                                      color: AppColor
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          35),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    'Absen Masuk',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  if (snapshot.data[
                                                                              'data']
                                                                          [
                                                                          'jam_masuk'] ==
                                                                      null) ...[
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {},
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          padding: EdgeInsets.symmetric(
                                                                              vertical: 4,
                                                                              horizontal: 4),
                                                                          backgroundColor:
                                                                              AppColor.warning,
                                                                          minimumSize: Size(
                                                                              50,
                                                                              20),
                                                                          tapTargetSize:
                                                                              MaterialTapTargetSize.shrinkWrap,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Belum Presensi',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10),
                                                                        )),
                                                                  ] else if (snapshot
                                                                              .data['data']
                                                                          [
                                                                          'jam_masuk'] !=
                                                                      null) ...[
                                                                    SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    Text(
                                                                      '${snapshot.data['data']['jam_masuk']}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              19,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ]
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    5,
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    'Absen Pulang',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  if (snapshot.data[
                                                                              'data']
                                                                          [
                                                                          'jam_pulang'] ==
                                                                      null) ...[
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {},
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          padding: EdgeInsets.symmetric(
                                                                              vertical: 4,
                                                                              horizontal: 4),
                                                                          backgroundColor:
                                                                              AppColor.warning,
                                                                          minimumSize: Size(
                                                                              50,
                                                                              20),
                                                                          tapTargetSize:
                                                                              MaterialTapTargetSize.shrinkWrap,
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          'Belum Presensi',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10),
                                                                        )),
                                                                  ] else if (snapshot
                                                                              .data['data']
                                                                          [
                                                                          'jam_pulang'] !=
                                                                      null) ...[
                                                                    SizedBox(
                                                                        height:
                                                                            6),
                                                                    Text(
                                                                      '${snapshot.data['data']['jam_pulang']}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              19,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )
                                                                  ]
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                30,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                  'Keterangan'),
                                                              SizedBox(
                                                                height: 6,
                                                              ),
                                                              if (snapshot.data[
                                                                          'data']
                                                                      [
                                                                      'keterangan'] ==
                                                                  "On Time") ...[
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {},
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              9),
                                                                      backgroundColor:
                                                                          AppColor
                                                                              .success,
                                                                      minimumSize:
                                                                          Size(
                                                                              50,
                                                                              20),
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                    ),
                                                                    child: Text(
                                                                      'On Time',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              10),
                                                                    )),
                                                              ] else if (snapshot
                                                                              .data[
                                                                          'data']
                                                                      [
                                                                      'keterangan'] ==
                                                                  "Terlambat") ...[
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {},
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              9),
                                                                      backgroundColor:
                                                                          AppColor
                                                                              .danger,
                                                                      minimumSize:
                                                                          Size(
                                                                              50,
                                                                              20),
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                    ),
                                                                    child: Text(
                                                                      'Terlambat',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              10),
                                                                    )),
                                                              ] else if (snapshot
                                                                              .data[
                                                                          'data']
                                                                      [
                                                                      'keterangan'] ==
                                                                  null) ...[
                                                                Text(
                                                                  '-',
                                                                  style: TextStyle(
                                                                      color: Color
                                                                          .fromARGB(
                                                                              255,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ]
                                                            ],
                                                          )
                                                        ]),
                                                  )
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 65,
                                  ),
                                  if (snapshot.data['data']['jam_masuk'] ==
                                      null) ...[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 17, right: 17),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          checkGps();
                                        },
                                        color: AppColor.warning,
                                        height: 20,
                                        minWidth: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "Presensi Masuk",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ] else if (snapshot.data['data']
                                              ['jam_masuk'] !=
                                          null &&
                                      snapshot.data['data']['jam_pulang'] ==
                                          null) ...[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 17, right: 17),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          checkGps();
                                        },
                                        color: AppColor.warning,
                                        height: 20,
                                        minWidth: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "Presensi Pulang",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ] else if (snapshot.data['data']
                                              ['jam_masuk'] !=
                                          null &&
                                      snapshot.data['data']['jam_pulang'] !=
                                          null) ...[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 17, right: 17),
                                      child: MaterialButton(
                                        onPressed: () async {},
                                        color: AppColor.success,
                                        height: 20,
                                        minWidth: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "Selamat Beristirahat",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
