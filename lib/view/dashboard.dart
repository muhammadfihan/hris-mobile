import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/cuti/cuti.dart';
import 'package:hris_apps/view/gaji/gaji.dart';
import 'package:hris_apps/view/izin/izin.dart';
import 'package:hris_apps/view/job/job.dart';
import 'package:hris_apps/view/laporan/laporan.dart';
import 'package:hris_apps/view/lembur/lembur.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/presensi/kehadiran.dart';
import 'package:hris_apps/view/reqabsen/reqabsen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

  Future getPengumuman() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'getpengumumanpeg'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var pengumumanpeg = json.decode(response.body);
    if (pengumumanpeg['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ));
    } else {
      return pengumumanpeg;
    }
  }

  @override
  Widget build(BuildContext context) {
    // getPengumuman();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HRIS APPS',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          FutureBuilder(
            future: getAkun(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(right: 9),
                    child: CircleAvatar(),
                  ),
                );
              } else {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(right: 9),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://prisen.online/files/${snapshot.data['logo']}'),
                    ),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: 30, left: 20, bottom: 25),
                                child: FutureBuilder(
                                  future: getAkun(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
                                      return Text(
                                        'Null',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF5F72E4),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        'Hi, ${snapshot.data['data']['name']}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF5F72E4),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 157,
                            child: Container(
                              margin: EdgeInsets.only(left: 17, right: 17),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
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
                              child: FutureBuilder(
                                future: getAkun(),
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
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(
                                            'NIP. Null',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        ListTile(
                                          title: Text('Null',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 8,
                                        ),
                                        ListTile(
                                          title: Text(
                                              '${snapshot.data['jabatan']}',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(
                                            'NIP. ${snapshot.data['nopegawai']}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        ListTile(
                                          title: Text('${snapshot.data['pt']}',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 30, left: 20),
                            child: Column(
                              children: [
                                Text(
                                  "Menu Utama",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(top: 20, right: 20, left: 20),
                            child: GridView.count(
                              shrinkWrap: true,
                              primary: false,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 4,
                              crossAxisCount: 4,
                              children: [
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Izin()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.event_available_outlined,
                                          color: AppColor.success,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Izin',
                                          style: TextStyle(
                                            color: Color(0xFF2DCE89),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Cuti()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.free_cancellation_outlined,
                                          color: AppColor.primary,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Cuti',
                                          style: TextStyle(
                                            color: Color(0xFF5F72E4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Lembur()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.more_time,
                                          color: AppColor.warning,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Lembur',
                                          style: TextStyle(
                                            color: Color(0xFFFB6340),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                ReqAbsen()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.published_with_changes,
                                          color: AppColor.info,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Req Absen',
                                          style: TextStyle(
                                            color: Color(0xFF0FCDEF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Gaji()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.account_balance_wallet_outlined,
                                          color: AppColor.danger,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Gaji',
                                          style: TextStyle(
                                            color: Color(0xFFF5365C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Laporan()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.pending_actions,
                                          color: Color(0xFFD376FF),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Laporan',
                                          style: TextStyle(
                                            color: Color(0xFFD376FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Job()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.work_history_outlined,
                                          color: Color(0xFF00A3FF),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Job',
                                          style: TextStyle(
                                            color: Color(0xFF00A3FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext ctx) =>
                                                Kehadiran()))
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          size: 38,
                                          Icons.event_repeat_outlined,
                                          color: Color(0xFFFF63EF),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Kehadiran',
                                          style: TextStyle(
                                            color: Color(0xFFFF63EF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Text(
                                  "Pengumuman Kantor",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 15),
                    height: MediaQuery.of(context).size.height / 6.1,
                    child: FutureBuilder(
                        future: getPengumuman(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data['data'].length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                255, 219, 219, 219)),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                    height:
                                        MediaQuery.of(context).size.height / 5,
                                    width: MediaQuery.of(context).size.width /
                                        1.14,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 6.0,
                                                color: AppColor.primary),
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                            left: 12, top: 5, right: 3),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${snapshot.data['data'][index]['judul']} (${snapshot.data['data'][index]['tanggal_pengumuman']})",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Text(
                                                "${snapshot.data['data'][index]['isi']}",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      26),
                                              ButtonBar(
                                                children: <Widget>[
                                                  TextButton(
                                                      onPressed: () async {
                                                        QuickAlert.show(
                                                          context: context,
                                                          type: QuickAlertType
                                                              .info,
                                                          confirmBtnColor:
                                                              AppColor.primary,
                                                          title:
                                                              '${snapshot.data['data'][index]['judul']} ',
                                                          text:
                                                              'Tanggal ${snapshot.data['data'][index]['tanggal_pengumuman']} | ${snapshot.data['data'][index]['isi']}',
                                                        );
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        minimumSize:
                                                            Size(50, 20),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      child: Text(
                                                        'Detail',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF5F72E4),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ),
                                  );
                                });
                          }
                        }),
                  ),
                ],
              ),
              Positioned(
                  right: 35,
                  top: 125,
                  child: Container(
                    child: MaterialButton(
                      shape: CircleBorder(),
                      child: Icon(
                        size: 70,
                        Icons.person,
                        color: AppColor.primary,
                      ),
                      color: Color.fromARGB(255, 255, 255, 255),
                      onPressed: () async {},
                    ), //Ico,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
