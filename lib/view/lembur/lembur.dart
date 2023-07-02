import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:hris_apps/view/lembur/ajukanlembur.dart';
import 'package:hris_apps/view/lembur/updatelembur.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class Lembur extends StatefulWidget {
  const Lembur({super.key});

  @override
  State<Lembur> createState() => _LemburState();
}

class _LemburState extends State<Lembur> {
  ScrollController _controller = new ScrollController();
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

  Future detaillembur() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response = await http
        .get(Uri.parse(baseURL + 'detaillemburmobile/${id}'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var detlembur = json.decode(response.body);
    if (detlembur['message'] == "Unauthenticated.") {
      localStorage.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } else {
      return detlembur;
    }
  }

  deletelembur() async {
    return QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        confirmBtnColor: AppColor.success,
        title: 'Hapus Lembur',
        text: 'Apakah anda ingin menghapus lembur ?',
        confirmBtnText: 'Hapus',
        onConfirmBtnTap: () async {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          var token = await localStorage
              .getString("token")
              .toString()
              .replaceAll('"', '');

          final response = await http
              .delete(Uri.parse(baseURL + 'hapuslembur/${id}'), headers: {
            'Content-Type': 'application/json; Charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });
          var dellembur = json.decode(response.body);
          if (dellembur['message'] == "Unauthenticated.") {
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
              getLembur();
            });
            return QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              confirmBtnColor: AppColor.primary,
              title: 'Berhasil',
              text: 'Anda Telah Menghapus Lembur',
            );
          }
        });
  }

  updatelembur() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(baseURL + 'updatelemburmobile/${id}'));
    request.headers.addAll(headers);
    request.fields['aktifitas'] = aktivitasupdt.text;
    request.fields['tanggal_lembur'] = tanggalupdt.text;
    request.fields['jumlah_jam'] = jumlahjamupdt.text;
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
          'buktilembur',
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
        tanggalupdt.clear();
        buktiupdt.clear();
        aktivitasupdt.clear();
        setState(() {
          getLembur();
        });
        return QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnColor: AppColor.primary,
          title: 'Berhasil',
          text: 'Anda Telah Mengupdate Lembur',
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
        );
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future refresh() async {
    setState(() {
      getLembur();
    });
  }

  @override
  void _show(BuildContext ctx) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  margin:
                      EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      setState(() {
                                        Tanggal.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {}
                                  },
                                  child: Icon(Icons.date_range)),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
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
            ));
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
        builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  margin:
                      EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Pengajuan Lembur',
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
                        child: TextFormField(
                          key: Key(txtNama),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama file harus diisi';
                            } else {
                              return null;
                            }
                          },
                          controller: aktivitasupdt,
                          onSaved: (String? val) {
                            aktivitasupdt.text = val!;
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
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
                          controller: jumlahjamupdt,
                          onSaved: (String? val) {
                            jumlahjamupdt.text = val!;
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
                        child: TextField(
                          controller: tanggalupdt,
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      setState(() {
                                        tanggalupdt.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {}
                                  },
                                  child: Icon(Icons.date_range)),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: InputBorder.none,
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
                              controller: buktiupdt,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Upload Bukti Lembur",
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
                        height: 20,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          updatelembur();
                        },
                        color: Color(0xFFFB6340),
                        height: 20,
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          "Update Lembur",
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
      detaillembur();
    });
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        elevation: 100,
        backgroundColor: Colors.white,
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
                        future: detaillembur(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Pengajuan Lembur',
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
                                          snapshot.data['data']['aktifitas']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Jumlah Jam Lembur',
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
                                          '${snapshot.data['data']['jumlah_jam'].toString()} Jam'),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Tanggal Lembur',
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
                                      child: Text(snapshot.data['data']
                                          ['tanggal_lembur']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Bukti Lembur',
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
                                          snapshot.data['data']['buktilembur']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Status Pengajuan',
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
                                      child: Text(snapshot.data['data']
                                          ['status_lembur']),
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

  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.info_outline,
            ),
            tooltip: 'Comment Icon',
            color: Color(0xFF5F72E4),
            onPressed: () async {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                confirmBtnColor: AppColor.primary,
                title: 'Informasi Lembur',
                text:
                    'Ketika lembur Anda disetujui maka perhitungan upah lembur Anda akan langsung dihitung dipenggajian akhir, dan dihitung berdasarkan UUD yang berlaku tentang Upah Lembur',
              );
            },
          ), //Icon
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
            ),
            tooltip: 'Comment Icon',
            color: Color(0xFF5F72E4),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AjukanLembur(),
                  ));
            },
          ), //IconButton
        ], //<Widget>[]
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(), // new
            controller: _controller,
            children: [
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                child: FutureBuilder(
                    future: getLembur(),
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
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
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
                                height:
                                    MediaQuery.of(context).size.height / 5.4,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      border: Border(
                                        left: BorderSide(
                                          width: 6.0,
                                          color: Color(0xFFFB6340),
                                        ),
                                      ),
                                    ),
                                    padding:
                                        const EdgeInsets.only(left: 12, top: 5),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${snapshot.data['data'][index]['aktifitas']}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: AppColor.darkgrey,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Status : ',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              if (snapshot.data['data'][index]
                                                      ['status_lembur'] ==
                                                  "Diterima") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_lembur']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.success,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                          [index]
                                                      ['status_lembur'] ==
                                                  "Ditolak") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_lembur']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.danger,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                          [index]
                                                      ['status_lembur'] ==
                                                  "Diproses") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_lembur']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.primary,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Tanggal Lembur : ",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "${snapshot.data['data'][index]['tanggal_lembur']}",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
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
                                                "Jumlah Jam Lembur : ",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "${snapshot.data['data'][index]['jumlah_jam']} Jam",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ButtonBar(
                                            buttonPadding:
                                                EdgeInsets.only(right: 10),
                                            children: <Widget>[
                                              if (snapshot.data['data'][index]
                                                      ['status_lembur'] ==
                                                  "Diproses") ...[
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: const Icon(
                                                    size: 18,
                                                    Icons.remove_red_eye,
                                                  ),
                                                  color: AppColor.primary,
                                                  onPressed: () async {
                                                    id = int.parse(
                                                        snapshot.data['data']
                                                            [index]['id']);
                                                    _detail(context);
                                                  },
                                                ), //Icon
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: const Icon(
                                                    size: 18,
                                                    Icons.edit_outlined,
                                                  ),
                                                  color: AppColor.success,
                                                  onPressed: () async {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateLembur(
                                                          uid: int.parse(
                                                              snapshot.data[
                                                                      'data'][
                                                                  index]['id']),
                                                          tgl: (snapshot.data[
                                                                  'data'][index]
                                                              [
                                                              'tanggal_lembur']),
                                                          aktifitas: (snapshot
                                                                      .data[
                                                                  'data'][index]
                                                              ['aktifitas']),
                                                          jumlh: (snapshot.data[
                                                                  'data'][index]
                                                              ['jumlah_jam']),
                                                          file: (snapshot.data[
                                                                  'data'][index]
                                                              ['buktilembur']),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ), //IconButton
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: const Icon(
                                                    size: 18,
                                                    Icons.delete,
                                                  ),
                                                  color: AppColor.danger,
                                                  onPressed: () async {
                                                    id = int.parse(
                                                        snapshot.data['data']
                                                            [index]['id']);
                                                    deletelembur();
                                                  },
                                                ), //IconButton
                                              ] else ...[
                                                TextButton(
                                                    onPressed: () async {
                                                      id = int.parse(
                                                          snapshot.data['data']
                                                              [index]['id']);
                                                      _detail(context);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.only(
                                                          right: 9),
                                                      minimumSize: Size(50, 20),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    child: Text(
                                                      'Detail',
                                                      style: TextStyle(
                                                        color: AppColor.primary,
                                                      ),
                                                    )),
                                              ]
                                            ], //<Widget>[]
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            });
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
