import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/cuti/cuti.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class AjukanCuti extends StatefulWidget {
  const AjukanCuti({super.key});

  @override
  State<AjukanCuti> createState() => _AjukanCutiState();
}

class _AjukanCutiState extends State<AjukanCuti> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String txtNama = "";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";

  var JenisCuti = TextEditingController();
  var BuktiCuti = TextEditingController();
  var TanggalMulai = TextEditingController();
  var TanggalSelesai = TextEditingController();
  var Keterangan = TextEditingController();

  int id = 0;
  var updtmulai = TextEditingController();
  var updtselesai = TextEditingController();
  var updtbukti = TextEditingController();
  var updtketerangan = TextEditingController();
  var updtjeniscuti = TextEditingController();

  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    TanggalMulai.text = "";
    TanggalSelesai.text = "";
    updtmulai.text = "";
    updtselesai.text = ""; //set the initial value of text field
    super.initState();
  }

  selectFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        BuktiCuti.text = result.files.single.name;
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
        updtbukti.text = result.files.single.name;
        filePickerValupdt = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  Future getCuti() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'tampilcutimobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var cuti = json.decode(response.body);
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

  void alert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      confirmBtnColor: AppColor.primary,
      title: 'Berhasil',
      text: 'Anda Telah Mengajukan Cuti',
    );
  }

  ajukancuti() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    final String jenis_cuti = JenisCuti.text; //txtNama;
    final String keterangan = Keterangan.text;
    final String tanggal_mulai = TanggalMulai.text; //txtNama;
    final String tanggal_akhir = TanggalSelesai.text;

    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request =
          http.MultipartRequest('POST', Uri.parse(baseURL + 'tambahcuti'));

      request.headers.addAll(headers);
      request.fields['jenis_cuti'] = jenis_cuti;
      request.fields['keterangan'] = keterangan;
      request.fields['tanggal_mulai'] = tanggal_mulai;
      request.fields['tanggal_akhir'] = tanggal_akhir;

      request.files.add(http.MultipartFile('bukti_cuti',
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
        TanggalMulai.clear();
        BuktiCuti.clear();
        JenisCuti.clear();
        Keterangan.clear();
        TanggalSelesai.clear();
        setState(() {
          getCuti();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Izin',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Cuti(),
                )).then((value) => getCuti());
          },
        );
      }
      if (res.statusCode == 203) {
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnColor: AppColor.primary,
          title: 'Gagal',
          text: 'Anda Memiliki Cuti Yang Belum Diproses',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Cuti(),
                )).then((value) => getCuti());
          },
        );
      }
    } catch (e) {
      debugPrint('$e');
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
          'Cuti',
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
                'Pengajuan Cuti',
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
                'Jenis Cuti',
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
                  controller: JenisCuti,
                  onSaved: (String? val) {
                    JenisCuti.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Jenis Cuti",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Keterangan Pengajuan',
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
                  controller: Keterangan,
                  onSaved: (String? val) {
                    Keterangan.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Alasan Pengajuan Cuti",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tanggal Mulai Cuti',
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
                  controller: TanggalMulai,
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
                                TanggalMulai.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                          child: Icon(Icons.date_range)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                      hintText: "Masukan Tanggal Mulai Cuti Anda",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tanggal Berakhir Cuti',
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
                  controller: TanggalSelesai,
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
                                TanggalSelesai.text =
                                    formattedDate; //set output date to TextField value.
                              });
                            } else {}
                          },
                          child: Icon(Icons.date_range)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: InputBorder.none,
                      hintText: "Masukan Tanggal Mulai Cuti Anda",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Upload Bukti/Surat Pengajuan',
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
                      controller: BuktiCuti,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Upload Bukti Pendukung",
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
                  ajukancuti();
                },
                color: Color(0xFFFB6340),
                height: 20,
                minWidth: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  "Ajukan Cuti",
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
