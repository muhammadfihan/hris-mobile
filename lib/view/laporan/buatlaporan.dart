import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:hris_apps/view/laporan/laporan.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class AjukanLaporan extends StatefulWidget {
  const AjukanLaporan({super.key});

  @override
  State<AjukanLaporan> createState() => _AjukanLaporanState();
}

class _AjukanLaporanState extends State<AjukanLaporan> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String txtNama = "";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";

  var Deskripsi = TextEditingController();
  var Bukti = TextEditingController();
  var TanggalLaporan = TextEditingController();

  int id = 0;
  var deskripsiupdt = TextEditingController();
  var tanggallaporanupdt = TextEditingController();
  var buktiupdt = TextEditingController();

  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    TanggalLaporan.text = "";
    tanggallaporanupdt.text = ""; //set the initial value of text field
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

  Future getLaporan() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'tampillaporanmobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var laporan = json.decode(response.body);
    if (laporan['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return laporan;
    }
  }

  Future detaillaporan() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response = await http
        .get(Uri.parse(baseURL + 'detaillaporanmobile/${id}'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var detlaporan = json.decode(response.body);
    if (detlaporan['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return detlaporan;
    }
  }

  deletelaporan() async {
    return QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnColor: AppColor.success,
        title: 'Hapus Laporan',
        text: 'Apakah anda ingin menghapus laporan ?',
        confirmBtnText: 'Hapus',
        onConfirmBtnTap: () async {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          var token = await localStorage
              .getString("token")
              .toString()
              .replaceAll('"', '');

          final response = await http
              .delete(Uri.parse(baseURL + 'hapuslaporan/${id}'), headers: {
            'Content-Type': 'application/json; Charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });
          var dellaporan = json.decode(response.body);
          if (dellaporan['message'] == "Unauthenticated.") {
            localStorage.remove('token');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const LoginScreen(),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              getLaporan();
            });
            return QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              confirmBtnColor: AppColor.primary,
              title: 'Berhasil',
              text: 'Anda Telah Menghapus Laporan',
            );
          }
        });
  }

  updatelaporan() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseURL + 'updatelaporanmobile/${id}'));
    request.headers.addAll(headers);
    request.fields['deskripsi'] = deskripsiupdt.text;
    request.fields['tanggal_laporan'] = tanggallaporanupdt.text;
    if (filePickerValupdt == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.primary,
        title: 'Gagal',
        text: 'File Tidak Boleh Kosong',
      );
    } else {
      request.files.add(http.MultipartFile(
          'lampiran',
          filePickerValupdt!.readAsBytes().asStream(),
          filePickerValupdt!.lengthSync(),
          filename: filePickerValupdt!.path.split("/").last));
      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        tanggallaporanupdt.clear();
        buktiupdt.clear();
        deskripsiupdt.clear();
        setState(() {
          getLaporan();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengumpulkan Laporan',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Laporan(),
                )).then((value) => getLaporan());
          },
        );
      } else {}
    }
  }

  void alert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      confirmBtnColor: AppColor.primary,
      title: 'Berhasil',
      text: 'Anda Telah Mengajukan Laporan',
    );
  }

  ajukanlaporan() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    final String deskripsi = Deskripsi.text; //txtNama;
    final String tanggal_laporan = TanggalLaporan.text;
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request =
          http.MultipartRequest('POST', Uri.parse(baseURL + 'tambahlaporan'));

      request.headers.addAll(headers);
      request.fields['deskripsi'] = deskripsi;
      request.fields['tanggal_laporan'] = tanggal_laporan;

      request.files.add(http.MultipartFile('lampiran',
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
        TanggalLaporan.clear();
        Bukti.clear();
        Deskripsi.clear();
        setState(() {
          getLaporan();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Laporan',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Laporan(),
                )).then((value) => getLaporan());
          },
        );
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF5F72E4),
        ),
        centerTitle: false,
        leadingWidth: 22,
        title: Text(
          'Laporan',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ), //<Widget>[]
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25, left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengumpulan Laporan',
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
                'Judul',
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
                    borderRadius: const BorderRadius.all(Radius.circular(7))),
                child: TextFormField(
                  key: Key(txtNama),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama file harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: Deskripsi,
                  onSaved: (String? val) {
                    Deskripsi.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Judul/Kegiatan Laporan",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tanggal Laporan',
                style: TextStyle(color: AppColor.primary, fontSize: 15),
              ),
              SizedBox(height: 7),
              Container(
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF5F72E4),
                    ),
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: const BorderRadius.all(Radius.circular(7))),
                child: TextField(
                  controller: TanggalLaporan,
                  readOnly: true,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2100));

                            if (pickedDate != null) {
                              print(
                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              print(
                                  formattedDate); //formatted date output using intl package =>  2021-03-16
                              setState(() {
                                TanggalLaporan.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                          child: Icon(Icons.date_range)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                      hintText: "Masukan Tanggal Laporan Anda",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Upload Lampiran',
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
                          hintText: "Upload File Laporan",
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
                    label: const Text('File', style: TextStyle(fontSize: 14.0)),
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
                  ajukanlaporan();
                },
                color: Color(0xFFFB6340),
                height: 20,
                minWidth: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  "Submit Laporan",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
