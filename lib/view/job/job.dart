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

class Job extends StatefulWidget {
  const Job({super.key});

  @override
  State<Job> createState() => _JobState();
}

class _JobState extends State<Job> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    //set the initial value of text field
    super.initState();
  }

  selectFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        Bukti.text = result.files.single.name;
        filePickerVal = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectFileupdt() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        print(result);
        buktiupdt.text = result.files.single.name;
        filePickerValupdt = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  Future refresh() async {
    setState(() {
      getJob();
      getAkun();
    });
  }

  Future getAkun() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response = await http.get(Uri.parse(baseURL + 'countjob'), headers: {
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
      return user['data'];
    }
  }

  Future getJob() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'getjobprogress'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var jobpegawai = json.decode(response.body);
    if (jobpegawai['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return jobpegawai;
    }
  }

  Future detailJob() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'detjobmobile/${id}'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var jobpegawai = json.decode(response.body);
    print(jobpegawai);
    if (jobpegawai['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return jobpegawai;
    }
  }

  submitjob() async {
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
          'POST', Uri.parse(baseURL + 'submitjobmobile/${id}'));

      request.headers.addAll(headers);

      request.files.add(http.MultipartFile('pengumpulan',
          filePickerVal!.readAsBytes().asStream(), filePickerVal!.lengthSync(),
          filename: filePickerVal!.path.split("/").last));

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        Bukti.clear();
        setState(() {
          getJob();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Berhasil Mengumpulkan Tugas',
        );
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _show(BuildContext ctx) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        elevation: 100,
        backgroundColor: Colors.white,
        context: ctx,
        isScrollControlled: true,
        builder: (ctx) => Container(
              key: _formKey,
              width: 300,
              child: Container(
                margin:
                    EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Job',
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
                        'Upload Job',
                        style: TextStyle(color: AppColor.primary, fontSize: 15),
                      ),
                      SizedBox(height: 7),
                      Container(
                        height: 40,
                        child: Row(children: [
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 1.48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF5F72E4),
                                ),
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(7))),
                            child: TextFormField(
                              readOnly: true,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'File harus diupload';
                                } else {
                                  return null;
                                }
                              },
                              controller: Bukti,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Upload Tugas Anda",
                                  hintStyle: TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.only(
                                      top: 2, left: 6, right: 6, bottom: 10)),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                              size: 24.0,
                            ),
                            label: const Text('File',
                                style: TextStyle(fontSize: 14.0)),
                            onPressed: () {
                              selectFile();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              minimumSize: const Size(95, 48),
                              maximumSize: const Size(95, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          submitjob();
                        },
                        color: Color(0xFFFB6340),
                        height: 20,
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          "Submit Job",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  void _detail(BuildContext ctx) {
    setState(() {
      detailJob();
    });
    showDialog(
        context: context,
        builder: (context) => FutureBuilder(
            future: detailJob(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data['data']['status'] != 'Revisi') {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: Text('${snapshot.data['data']['judul_job']}'),
                    content: Text('${snapshot.data['data']['deskripsi']}'),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('Tutup'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                } else {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title:
                        Text('${snapshot.data['data']['judul_job']} (Revisi)'),
                    content: Text('${snapshot.data['data']['revisi']}'),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('Tutup'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    getJob();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF5F72E4),
        ),
        centerTitle: false,
        leadingWidth: 22,
        title: Text(
          'Job Assignment',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        actions: <Widget>[], //<Widget>[]
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: 30, left: 20, bottom: 18, right: 20),
                      child: Row(
                        children: <Widget>[
                          FutureBuilder(
                            future: getAkun(),
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
                                  'Job Management',
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
                            future: getAkun(),
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
                                            builder: (BuildContext context) =>
                                                JobHistory(),
                                          ));
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(50, 20),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: AppColor.primary,
                                      ),
                                    ));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 129,
                                width: MediaQuery.of(context).size.width / 2,
                                child: Card(
                                  margin: EdgeInsets.only(left: 17, right: 17),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Color.fromRGBO(95, 114, 228, 1),
                                  elevation: 10,
                                  child: FutureBuilder(
                                    future: getAkun(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ));
                                      } else {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 18),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            '${snapshot.data['selesai']}',
                                                            style: TextStyle(
                                                                fontSize: 40.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(' Jobs',
                                                            style: TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.white,
                                                            ))
                                                      ],
                                                    ),
                                                    Text('Complete',
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ]),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 0,
                              ),
                              Container(
                                height: 129,
                                width: MediaQuery.of(context).size.width / 2,
                                child: Card(
                                  margin: EdgeInsets.only(left: 17, right: 17),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: AppColor.warning,
                                  elevation: 10,
                                  child: FutureBuilder(
                                    future: getAkun(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ));
                                      } else {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 18),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            '${snapshot.data['pending']}',
                                                            style: TextStyle(
                                                                fontSize: 40.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(' Jobs',
                                                            style: TextStyle(
                                                              fontSize: 20.0,
                                                              color:
                                                                  Colors.white,
                                                            ))
                                                      ],
                                                    ),
                                                    Text('Pending',
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ]),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 28, left: 20, bottom: 18, right: 20),
                      child: Row(
                        children: <Widget>[
                          FutureBuilder(
                            future: getAkun(),
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
                                  'Upcoming Job',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                );
                              }
                            },
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.8,
                      child: FutureBuilder(
                        future: getJob(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data['data'].length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: Column(children: [
                                      if (snapshot.data['data'][index]
                                              ['status'] !=
                                          "Revisi") ...[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              6,
                                          margin: EdgeInsets.only(
                                              left: 20, bottom: 18, right: 20),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(3, 3),
                                                  spreadRadius: -3,
                                                  blurRadius: 5,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                )
                                              ],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10.0)),
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 9, top: 9, right: 9),
                                              height: 100,
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColor
                                                                .darkgrey,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          'New Task',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: AppColor
                                                                  .primary,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )
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
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          '${snapshot.data['data'][index]['deadline']}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          '${snapshot.data['data'][index]['status']}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: AppColor
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    if (snapshot.data['data']
                                                            [index]['status'] ==
                                                        "Checking") ...[
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          TextButton(
                                                              onPressed:
                                                                  () async {},
                                                              style: TextButton
                                                                  .styleFrom(
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Submitted',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              )),
                                                        ], //<Widget>[]
                                                      ),
                                                    ] else if (snapshot
                                                                .data['data']
                                                            [index]['status'] !=
                                                        "Checking") ...[
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                id = int.parse(snapshot
                                                                            .data[
                                                                        'data'][
                                                                    index]['id']);
                                                                _detail(
                                                                    context);
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .warning,
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Detail',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        11),
                                                              )),
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                id = int.parse(snapshot
                                                                            .data[
                                                                        'data'][
                                                                    index]['id']);
                                                                _show(context);
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .primary,
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Submit',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        11),
                                                              )), //IconB //IconButton
                                                        ], //<Widget>[]
                                                      ),
                                                    ],
                                                  ]),
                                            ),
                                          ),
                                        )
                                      ] else if (snapshot.data['data'][index]
                                              ['status'] ==
                                          "Revisi") ...[
                                        Container(
                                          height: 120,
                                          margin: EdgeInsets.only(
                                              left: 20, bottom: 18, right: 20),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(3, 3),
                                                  spreadRadius: -3,
                                                  blurRadius: 5,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                )
                                              ],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10.0)),
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 9, top: 9, right: 9),
                                              height: 100,
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                border: Border(
                                                  left: BorderSide(
                                                      width: 6.0,
                                                      color: AppColor.danger),
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColor
                                                                .darkgrey,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          'Revisi',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: AppColor
                                                                  .danger,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )
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
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          '${snapshot.data['data'][index]['deadline']}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          '${snapshot.data['data'][index]['status']}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                AppColor.danger,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    if (snapshot.data['data']
                                                            [index]['status'] ==
                                                        "Checking") ...[
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          TextButton(
                                                              onPressed:
                                                                  () async {},
                                                              style: TextButton
                                                                  .styleFrom(
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Submitted',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              )),
                                                        ], //<Widget>[]
                                                      ),
                                                    ] else if (snapshot
                                                                .data['data']
                                                            [index]['status'] !=
                                                        "Checking") ...[
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                id = int.parse(snapshot
                                                                            .data[
                                                                        'data'][
                                                                    index]['id']);
                                                                _detail(
                                                                    context);
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .warning,
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Detail',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12),
                                                              )),
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                id = int.parse(snapshot
                                                                            .data[
                                                                        'data'][
                                                                    index]['id']);
                                                                _show(context);
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    AppColor
                                                                        .primary,
                                                                minimumSize:
                                                                    Size(
                                                                        50, 20),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                'Submit',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12),
                                                              )), //IconB //IconButton
                                                        ], //<Widget>[]
                                                      ),
                                                    ],
                                                  ]),
                                            ),
                                          ),
                                        )
                                      ]
                                    ]),
                                  );
                                });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
