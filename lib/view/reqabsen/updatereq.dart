import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/reqabsen/buatreq.dart';
import 'package:hris_apps/view/reqabsen/reqabsen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class UpdateReq extends StatefulWidget {
  const UpdateReq(
      {Key? key,
      required this.alasan,
      required this.uid,
      required this.tgl,
      required this.file})
      : super(key: key);

  final uid;
  final alasan;
  final tgl;
  final file;
  @override
  State<UpdateReq> createState() => _UpdateReqState();
}

class _UpdateReqState extends State<UpdateReq> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String txtNama = "";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";

  var Alasan = TextEditingController();
  var Bukti = TextEditingController();
  var TanggalReq = TextEditingController();

  int id = 0;
  var alasanupdt = TextEditingController();
  var tanggalrequpdt = TextEditingController();
  var buktiupdt = TextEditingController();
  var urlpath = '';
  File? filedata;
  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    tanggalrequpdt.text = widget.tgl;
    alasanupdt.text = widget.alasan;
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

  Future getReq() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'allreqmobile'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var reqabsen = json.decode(response.body);
    if (reqabsen['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return reqabsen;
    }
  }

  Future detailreq() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'detailreqmobile/${id}'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var detreq = json.decode(response.body);
    if (detreq['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return detreq;
    }
  }

  deletereq() async {
    return QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnColor: AppColor.success,
        title: 'Hapus Request Absensi',
        text: 'Apakah anda ingin menghapus request ini ?',
        confirmBtnText: 'Hapus',
        onConfirmBtnTap: () async {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          var token = await localStorage
              .getString("token")
              .toString()
              .replaceAll('"', '');

          final response = await http
              .delete(Uri.parse(baseURL + 'hapusreqabsen/${id}'), headers: {
            'Content-Type': 'application/json; Charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });
          var delreq = json.decode(response.body);
          if (delreq['message'] == "Unauthenticated.") {
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
              getReq();
            });
            return QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              confirmBtnColor: AppColor.primary,
              title: 'Berhasil',
              text: 'Anda Telah Menghapus Request Attendance',
            );
          }
        });
  }

  updatereq() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseURL + 'updatereqabsenmobile/${widget.uid}'));
    request.headers.addAll(headers);
    request.fields['alasan'] = alasanupdt.text;
    request.fields['tanggal_req'] = tanggalrequpdt.text;
    if (buktiupdt.text == widget.file) {
      request.files.add(http.MultipartFile('bukti_pendukung',
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
        tanggalrequpdt.clear();
        buktiupdt.clear();
        alasanupdt.clear();
        setState(() {
          getReq();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Update Request Attendance',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ReqAbsen(),
                )).then((value) => getReq());
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
          'bukti_pendukung',
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
        tanggalrequpdt.clear();
        buktiupdt.clear();
        alasanupdt.clear();
        setState(() {
          getReq();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Update Request Attendance',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ReqAbsen(),
                )).then((value) => getReq());
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
      text: 'Anda Telah Mengajukan Request Attendance',
    );
  }

  ajukanreq() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    final String alasan = Alasan.text; //txtNama;
    final String tanggal = TanggalReq.text;
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request =
          http.MultipartRequest('POST', Uri.parse(baseURL + 'ajukanreqabsen'));

      request.headers.addAll(headers);
      request.fields['alasan'] = alasan;
      request.fields['tanggal_req'] = tanggal;

      request.files.add(http.MultipartFile('bukti_pendukung',
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
        TanggalReq.clear();
        Bukti.clear();
        Alasan.clear();
        setState(() {
          getReq();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengajukan Request Attendance',
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop(true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ReqAbsen(),
                )).then((value) => getReq());
          },
        );
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

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
          'Request Attendance',
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
                'Update Pengajuan Request Attendance',
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
                'Alasan',
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
                  controller: alasanupdt,
                  onSaved: (String? val) {
                    alasanupdt.text = val!;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Masukan Alasan",
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(
                          top: 10, left: 6, right: 6, bottom: 16)),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tanggal Request Attendance',
                style: TextStyle(color: AppColor.primary, fontSize: 15),
              ),
              SizedBox(height: 7),
              Container(
                height: 40,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF5F72E4),
                        ),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7))),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: DropdownSearch<String>(
                        selectedItem: tanggalrequpdt.text,
                        popupProps: PopupProps.dialog(
                          fit: FlexFit.loose,
                          dialogProps: DialogProps(
                            backgroundColor: Color.fromARGB(255, 255, 255, 255),
                            elevation: 0,
                          ),
                        ),
                        asyncItems: (String filter) async {
                          SharedPreferences localStorage =
                              await SharedPreferences.getInstance();
                          var token = await localStorage
                              .getString("token")
                              .toString()
                              .replaceAll('"', '');
                          var response = await http.get(
                              Uri.parse(baseURL + 'listtanggal'),
                              headers: {
                                'Content-Type':
                                    'application/json; Charset=UTF-8',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer $token',
                              });
                          List data = (json.decode(response.body)
                              as Map<String, dynamic>)['data'];
                          List<String> tanggal = [];
                          data.forEach((element) {
                            tanggal.add(element['tanggal']);
                          });
                          return tanggal;
                        },
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Pilih Tanggal",
                              hintStyle: TextStyle(
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.only(
                                  top: 5, left: 6, right: 6, bottom: 0)),
                        ),
                        onChanged: (tanggal) {
                          tanggalrequpdt.text = tanggal!;
                        },
                      ),
                    )),
              ),
              SizedBox(height: 7),
              Text(
                'Upload File',
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
                      controller: buktiupdt,
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
                      buktiupdt.text = 'Harap Tunggu...';
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
                            buktiupdt.text = savename;
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
                onPressed: () async {
                  updatereq();
                },
                color: Color(0xFFFB6340),
                height: 20,
                minWidth: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  "Update Request Attendance",
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
