import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/utils/rupiah.dart';
import 'package:hris_apps/view/login.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RiwayatGaji extends StatefulWidget {
  const RiwayatGaji({super.key});

  @override
  State<RiwayatGaji> createState() => _RiwayatGajiState();
}

class _RiwayatGajiState extends State<RiwayatGaji> {
  int id = 0;
  Future getRiwayat() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'riwayatfinalmobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var cuti = json.decode(response.body);
    if (cuti['data'] == null) {
      print('object');
    } else {
      if (cuti['message'] == "Unauthenticated.") {
        localStorage.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen(),
          ),
          (route) => false,
        );
      } else {
        return cuti;
      }
    }
  }

  Future detGaji() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'detriwayatmobile/${id}'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var gaji = json.decode(response.body);
    if (gaji['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return gaji;
    }
  }

  void _detail(BuildContext ctx) {
    setState(() {
      detGaji();
    });
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        elevation: 100,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: ctx,
        builder: (ctx) => Container(
              width: 300,
              child: Container(
                margin:
                    EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: detGaji(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Penggajian',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5F72E4),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Total Terima Bersih',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColor.secondary,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['gaji_bersih']), 2)}'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Bonus Lembur ${snapshot.data['data']['jamlembur_total']} Jam',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColor.secondary,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['total_lembur']), 2)}'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Total Tunjangan',
                                    style: TextStyle(
                                        color: AppColor.secondary,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 7),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['total_tunjangan']), 2)}'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Total Bonus',
                                    style: TextStyle(
                                        color: AppColor.secondary,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 7),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['total_bonus'].toString()), 2)}'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Potongan Tidak Bekerja ${snapshot.data['data']['tidak_masuk']} Hari',
                                    style: TextStyle(
                                        color: AppColor.secondary,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 7),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '-  ${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['potong_absen']), 2)}'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Total Potongan',
                                    style: TextStyle(
                                        color: AppColor.secondary,
                                        fontSize: 15),
                                  ),
                                  SizedBox(height: 7),
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFF5F72E4),
                                        ),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(7))),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          8), //apply padding to all four sides
                                      child: Text(
                                          '- ${RupiahFormat.convertToIdr(int.parse(snapshot.data['data']['total_potongan']), 2)}'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
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
                                      "Tutup",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    getRiwayat();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF5F72E4),
        ),
        centerTitle: false,
        leadingWidth: 22,
        title: Text(
          'Riwayat Gaji',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
          margin: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 6),
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: getRiwayat(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Visibility(
                        child: Text("Gone"),
                        visible: false,
                      );
                    } else {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data['data'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(children: [
                                Container(
                                  height: 120,
                                  margin: EdgeInsets.only(bottom: 18),
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(3, 3),
                                          spreadRadius: -3,
                                          blurRadius: 5,
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                        )
                                      ],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 9, top: 9, right: 9),
                                      height: 100,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        border: Border(
                                          left: BorderSide(
                                              width: 6.0,
                                              color: AppColor.primary),
                                        ),
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${RupiahFormat.convertToIdr(int.parse(snapshot.data['data'][index]['gaji_bersih']), 2)}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColor.darkgrey,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  '${snapshot.data['data'][index]['tanggal_ambil']}',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Jabatan : ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColor.darkgrey,
                                                  ),
                                                ),
                                                Text(
                                                  '${(snapshot.data['jabatan'][index].toString().replaceAll(']', '').replaceAll('[', ''))}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColor.darkgrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Status : ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColor.darkgrey,
                                                  ),
                                                ),
                                                Text(
                                                  '${snapshot.data['data'][index]['status']}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ButtonBar(
                                              children: <Widget>[
                                                TextButton(
                                                    onPressed: () async {
                                                      id = snapshot.data['data']
                                                          [index]['id'];
                                                      _detail(context);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          AppColor.warning,
                                                      minimumSize: Size(50, 20),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: Text(
                                                      'Detail',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    )),
                                              ], //<Widget>[]
                                            ),
                                          ]),
                                    ),
                                  ),
                                )
                              ]),
                            );
                          });
                    }
                  }),
            ]),
          )),
    );
  }
}
