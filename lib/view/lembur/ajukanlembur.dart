import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:hris_apps/view/lembur/lembur.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class AjukanLembur extends StatefulWidget {
  const AjukanLembur({super.key});

  @override
  State<AjukanLembur> createState() => _AjukanLemburState();
}

class _AjukanLemburState extends State<AjukanLembur> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String txtNama = "";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";

  var Aktivitas = TextEditingController();
  var JumlahJam = TextEditingController();
  var Bukti = TextEditingController();
  var Tanggal = TextEditingController();

  int id = 0;
  var aktivitasupdt = TextEditingController();
  var jumlahjamupdt = TextEditingController();
  var tanggalupdt = TextEditingController();
  var buktiupdt = TextEditingController();

  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    Tanggal.text = "";
    tanggalupdt.text = ""; //set the initial value of text field
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

  Future getLembur() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'tampillemburmobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var lembur = json.decode(response.body);
    print(lembur);
    if (lembur['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return lembur;
    }
  }

  void alert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      confirmBtnColor: AppColor.primary,
      title: 'Berhasil',
      text: 'Anda Telah Mengajukan Lembur',
    );
  }

  ajukanlembur() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    final String aktifitas = Aktivitas.text; //txtNama;
    final String tanggal = Tanggal.text;
    final String jumlah_jam = JumlahJam.text; //txtNama;
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request =
          http.MultipartRequest('POST', Uri.parse(baseURL + 'tambahlembur'));

      request.headers.addAll(headers);
      request.fields['aktifitas'] = aktifitas;
      request.fields['tanggal_lembur'] = tanggal;
      request.fields['jumlah_jam'] = jumlah_jam;

      request.files.add(http.MultipartFile('buktilembur',
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
        Tanggal.clear();
        Bukti.clear();
        JumlahJam.clear();
        Aktivitas.clear();
        setState(() {
          getLembur();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Lembur',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Lembur(),
                )).then((value) => getLembur());
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
          'Lembur',
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
                'Pengajuan Lembur',
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
                'Aktifitas',
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
                  controller: Aktivitas,
                  onSaved: (String? val) {
                    Aktivitas.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Aktifitas Lembur",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Jumlah Jam Lembur',
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
                  keyboardType: TextInputType.number,
                  key: Key(txtNama),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama file harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: JumlahJam,
                  onSaved: (String? val) {
                    JumlahJam.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Jumlah Lembur",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tanggal Lembur',
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
                  controller: Tanggal,
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
                                Tanggal.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                          child: Icon(Icons.date_range)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                      hintText: "Masukan Tanggal Lembur Anda",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Upload Bukti Lembur',
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
                          hintText: "Upload File Lembur",
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
                  ajukanlembur();
                },
                color: Color(0xFFFB6340),
                height: 20,
                minWidth: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  "Ajukan Lembur",
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
