import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/cuti/ajukancuti.dart';
import 'package:hris_apps/view/cuti/cuti.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class UpdateCuti extends StatefulWidget {
  const UpdateCuti(
      {Key? key,
      required this.tglmulai,
      required this.uid,
      required this.tglakhir,
      required this.keterangan,
      required this.jeniscuti,
      required this.file})
      : super(key: key);

  final uid;
  final tglmulai;
  final tglakhir;
  final jeniscuti;
  final keterangan;
  final file;

  @override
  State<UpdateCuti> createState() => _UpdateCutiState();
}

class _UpdateCutiState extends State<UpdateCuti> {
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
  var urlpath = '';
  File? filedata;

  void initState() {
    updtmulai.text = widget.tglmulai;
    updtselesai.text = widget.tglmulai;
    updtjeniscuti.text = widget.jeniscuti;
    updtketerangan.text = widget.keterangan;
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

  updatecuti() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseURL + 'updatecutimobile/${widget.uid}'));
    request.headers.addAll(headers);
    request.fields['jenis_cuti'] = updtjeniscuti.text;
    request.fields['keterangan'] = updtketerangan.text;
    request.fields['tanggal_mulai'] = updtmulai.text;
    request.fields['tanggal_akhir'] = updtselesai.text;
    if (updtbukti.text == widget.file) {
      request.files.add(http.MultipartFile('bukti_cuti',
          filedata!.readAsBytes().asStream(), filedata!.lengthSync(),
          filename: filedata!.path.split("/").last));
      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      //debug
      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      debugPrint(dataDecode.toString());

      if (res.statusCode == 200) {
        updtmulai.clear();
        updtbukti.clear();
        updtjeniscuti.clear();
        updtketerangan.clear();
        updtselesai.clear();
        // setState(() {
        //   getIzin();
        // });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengupdate Cuti',
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
      } else {}
    } else if (filePickerValupdt == null) {
      return QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        confirmBtnColor: AppColor.primary,
        title: 'Gagal',
        text: 'File Tidak Boleh Kosong',
      );
    } else {
      request.files.add(http.MultipartFile(
          'bukti_cuti',
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
        updtmulai.clear();
        updtbukti.clear();
        updtjeniscuti.clear();
        updtketerangan.clear();
        updtselesai.clear();
        setState(() {
          getCuti();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengupdate Cuti',
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
                  controller: updtjeniscuti,
                  onSaved: (String? val) {
                    updtjeniscuti.text = val!;
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
                  controller: updtketerangan,
                  onSaved: (String? val) {
                    updtketerangan.text = val!;
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
                  controller: updtmulai,
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
                                updtselesai.text =
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
                  controller: updtselesai,
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
                                updtselesai.text =
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
                      controller: updtbukti,
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
                      selectFileupdt();
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
                height: 8,
              ),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      updtbukti.text = 'Harap Tunggu...';
                    });
                    final status =
                        await Permission.manageExternalStorage.request();
                    if (status.isGranted) {
                      var dir = await DownloadsPathProvider.downloadsDirectory;
                      if (dir != null) {
                        String savename = widget.file;
                        String savePath = dir.path + "/$savename";
                        print(savePath);
                        try {
                          await Dio().download(
                              'https://prisen.online/files/${widget.file}',
                              savePath, onReceiveProgress: (received, total) {
                            if (total != -1) {
                              print(
                                  (received / total * 100).toStringAsFixed(0) +
                                      "%");

                              //you can build progressbar feature too
                            }
                          });
                          setState(() {
                            updtbukti.text = savename;
                            urlpath = savePath;
                            filedata = File(urlpath);
                          });
                        } on DioError catch (e) {
                          print(e.message);
                        }
                      }
                    } else {
                      throw PlatformException(
                        code: 'PERMISSION_DENIED',
                        message: 'Storage permission is required.',
                        details: null,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    ' Gunakan File Lama ?',
                    style: TextStyle(color: AppColor.primary, fontSize: 13),
                  )),
              SizedBox(
                height: 15,
              ),
              MaterialButton(
                onPressed: () {
                  updatecuti();
                },
                color: Color(0xFFFB6340),
                height: 20,
                minWidth: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  "Update Cuti",
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
