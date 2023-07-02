import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/api/globals.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/cuti/cuti.dart';
import 'package:hris_apps/view/izin/izin.dart';
import 'package:hris_apps/view/job/history.dart';
import 'package:hris_apps/view/laporan/laporan.dart';
import 'package:hris_apps/view/lembur/lembur.dart';
import 'package:hris_apps/view/login.dart';
import 'package:hris_apps/view/reqabsen/reqabsen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class JobHistory extends StatefulWidget {
  const JobHistory({super.key});

  @override
  State<JobHistory> createState() => _JobHistoryState();
}

class _JobHistoryState extends State<JobHistory> {
  Future getPengumuman() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'jobselesai'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var pengumumanpeg = json.decode(response.body);
    if (pengumumanpeg['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return pengumumanpeg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF5F72E4),
        ),
        centerTitle: false,
        leadingWidth: 22,
        title: Text(
          'Completed Job',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25, bottom: 6),
        child: SingleChildScrollView(
          child: Column(children: [
            FutureBuilder(
                future: getPengumuman(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3),
                        child: Center(child: CircularProgressIndicator()));
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
                                height: MediaQuery.of(context).size.height / 6,
                                margin: EdgeInsets.only(
                                    left: 20, bottom: 18, right: 20),
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
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      border: Border(
                                        left: BorderSide(
                                            width: 6.0,
                                            color: AppColor.success),
                                      ),
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${snapshot.data['data'][index]['judul_job']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColor.darkgrey,
                                                ),
                                              ),
                                              Spacer(),
                                              if (snapshot.data['data'][index]
                                                      ['keterangan'] ==
                                                  "Overdue") ...[
                                                Text(
                                                  'Overdue',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppColor.danger,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              ] else if (snapshot.data['data']
                                                      [index]['keterangan'] ==
                                                  "On Time") ...[
                                                Text(
                                                  'On Time',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppColor.success,
                                                      fontStyle:
                                                          FontStyle.italic),
                                                )
                                              ],
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Deadline : ',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${snapshot.data['data'][index]['deadline']}',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  onPressed: () async {},
                                                  style: TextButton.styleFrom(
                                                    minimumSize: Size(50, 20),
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  child: Text(
                                                    'Submitted',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
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
                })
          ]),
        ),
      ),
    );
  }
}
