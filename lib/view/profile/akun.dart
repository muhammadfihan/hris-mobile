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

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var NamaLengkap = TextEditingController();
  var Pendidikan = TextEditingController();
  var NoHp = TextEditingController();
  var Gender = TextEditingController();
  var Alamat = TextEditingController();
  var JenisRek = TextEditingController();
  var NoRek = TextEditingController();
  var Ttl = TextEditingController();
  var NoKtp = TextEditingController();

  int id = 0;

  Future getAkun() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'profilepegawaimobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var user = json.decode(response.body);
    if (user['message'] == "Unauthenticated.") {
      return Container(
          margin: EdgeInsets.only(top: 180),
          child: Center(child: CircularProgressIndicator()));
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

  updatedata() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request =
        http.MultipartRequest('POST', Uri.parse(baseURL + 'updatedata'));
    request.headers.addAll(headers);
    request.fields['nama_lengkap'] = NamaLengkap.text;
    request.fields['ttl'] = Ttl.text;
    request.fields['alamat'] = Alamat.text;
    request.fields['pendidikan'] = Pendidikan.text;
    request.fields['no_hp'] = NoHp.text;
    request.fields['no_ktp'] = NoKtp.text;
    request.fields['gender'] = Gender.text;
    request.fields['jenis_rek'] = JenisRek.text;
    request.fields['no_rek'] = NoRek.text;

    var res = await request.send();
    var responseBytes = await res.stream.toBytes();
    var responseString = utf8.decode(responseBytes);

    final dataDecode = jsonDecode(responseString);
    if (res.statusCode == 200) {
      if (dataDecode['success'] == true) {
        setState(() {
          getAkun();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengupdate Profile',
        );
      } else {
        setState(() {
          getAkun();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnColor: AppColor.primary,
          title: 'Gagal',
          text: 'Terjadi Kesalahan',
        );
      }
    } else {}
  }

  void _update(BuildContext ctx) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.2,
                child: Container(
                  margin:
                      EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Data',
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
                          'Nama Lengkap',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: NamaLengkap,
                            onSaved: (String? val) {
                              NamaLengkap.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Pendidikan',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: Pendidikan,
                            onSaved: (String? val) {
                              Pendidikan.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Nomo Handphone',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: NoHp,
                            onSaved: (String? val) {
                              NoHp.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Nomor KTP',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: NoKtp,
                            onSaved: (String? val) {
                              NoKtp.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: Gender,
                            onSaved: (String? val) {
                              Gender.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Alamat',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: Alamat,
                            onSaved: (String? val) {
                              Alamat.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Jenis Rekening',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: JenisRek,
                            onSaved: (String? val) {
                              JenisRek.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'No Rekening',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: NoRek,
                            onSaved: (String? val) {
                              NoRek.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Tanggal Lahir',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5F72E4),
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF5F72E4),
                              ),
                              color: Color.fromARGB(255, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          child: TextFormField(
                            controller: Ttl,
                            onSaved: (String? val) {
                              Ttl.text = val!;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(
                                    top: 10, left: 6, right: 6, bottom: 16)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            updatedata();
                          },
                          color: Color(0xFFFB6340),
                          height: 20,
                          minWidth: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Text(
                            "Update Data",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    // getPengumuman();
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height / 3.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      end: Alignment(0.8, 1),
                                      colors: <Color>[
                                        Color(0xff5e72e4),
                                        Color(0xff825ee4),
                                      ],
                                      tileMode: TileMode.mirror,
                                    ),
                                  ),
                                  child: Center(
                                    child: FutureBuilder(
                                      future: getAkun(),
                                      builder: (context, snapshot) {
                                        if (snapshot.data == null) {
                                          return Text('');
                                        } else {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      6,
                                                ),
                                                Center(
                                                  child: Text(
                                                      '${snapshot.data['biodata']['email']}',
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(
                                                  height: 7,
                                                ),
                                                Center(
                                                  child: Text(
                                                      'NIP ${snapshot.data['biodata']['no_pegawai']}',
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.white,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: getAkun(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Text('');
                                } else {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 30, left: 20, right: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Data Akun",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: AppColor.darkgrey,
                                          ),
                                        ),
                                        Spacer(),
                                        TextButton(
                                            onPressed: () async {
                                              NamaLengkap.text =
                                                  snapshot.data['biodata']
                                                      ['nama_lengkap'];
                                              Pendidikan.text =
                                                  snapshot.data['biodata']
                                                      ['pendidikan'];
                                              NoHp.text = snapshot
                                                  .data['biodata']['no_hp']
                                                  .toString();

                                              NoKtp.text = snapshot
                                                  .data['biodata']['no_ktp']
                                                  .toString();

                                              Gender.text = snapshot
                                                  .data['biodata']['gender'];
                                              Alamat.text = snapshot
                                                  .data['biodata']['alamat'];

                                              JenisRek.text = snapshot
                                                  .data['biodata']['jenis_rek'];
                                              NoRek.text = snapshot
                                                  .data['biodata']['no_rek']
                                                  .toString();

                                              Ttl.text = snapshot
                                                  .data['biodata']['ttl'];

                                              _update(context);
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(50, 20),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Update',
                                              style: TextStyle(
                                                color: AppColor.primary,
                                              ),
                                            ))
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            FutureBuilder(
                              future: getAkun(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Container(
                                      margin: EdgeInsets.only(top: 180),
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                } else {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          'Email',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['email']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Username',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['name']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Nama Lengkap',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['nama_lengkap']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Tanggal Lahir',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['ttl']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Jenis Kelamin',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['gender']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'No Handphone',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['no_hp']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Status',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['status']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Pendidikan',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['pendidikan']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Alamat',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['alamat']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Jenis Rekening',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['jenis_rek']}'),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'No Rekening',
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
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(7))),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                8), //apply padding to all four sides
                                            child: Text(
                                                '${snapshot.data['biodata']['no_rek']}'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        MaterialButton(
                                          onPressed: () async {
                                            // await QuickAlert.show(
                                            //     context: context,
                                            //     type: QuickAlertType.loading,
                                            //     title: 'Mohon Tunggu',
                                            //     text: 'Anda Akan Logout',
                                            //     autoCloseDuration:
                                            //         Duration(seconds: 3));
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            setState(() {
                                              preferences.remove("token");
                                              preferences.remove("user");
                                            });

                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const LoginScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          color: Color(0xFFFB6340),
                                          height: 20,
                                          minWidth: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          child: Text(
                                            "Logout",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              35,
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
                  ),
                ],
              ),
              Positioned(
                  // right: 35,
                  // top: 69,
                  child: Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 11.5),
                  child: Column(
                    children: [
                      MaterialButton(
                        shape: CircleBorder(),
                        child: Icon(
                          size: 75,
                          Icons.person,
                          color: AppColor.primary,
                        ),
                        color: Color.fromARGB(255, 255, 255, 255),
                        onPressed: () async {},
                      ),
                    ],
                  ),
                ), //Ico,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
