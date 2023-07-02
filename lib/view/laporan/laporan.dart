import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/izin/buatizin.dart';
import 'package:hris_apps/view/laporan/buatlaporan.dart';
import 'package:hris_apps/view/laporan/updatelaporan.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class Laporan extends StatefulWidget {
  const Laporan({super.key});

  @override
  State<Laporan> createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  ScrollController _controller = new ScrollController();

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

  Future refresh() async {
    setState(() {
      getLaporan();
    });
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
          text: 'Anda Telah Mengupdate Laporan',
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
        );
      } else {}
    } catch (e) {
      debugPrint('$e');
    }
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
              initialChildSize: 0.5,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  margin:
                      EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 10),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
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
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      setState(() {
                                        TanggalLaporan.text =
                                            formattedDate; //set output date to TextField value.
                                      });
                                    } else {}
                                  },
                                  child: Icon(Icons.date_range)),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
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
            ));
  }

  void _update(BuildContext ctx) {
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
                        'Update Laporan',
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
                          controller: deskripsiupdt,
                          onSaved: (String? val) {
                            deskripsiupdt.text = val!;
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "",
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7))),
                        child: TextField(
                          controller: tanggallaporanupdt,
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
                                        tanggallaporanupdt.text =
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
                          updatelaporan();
                        },
                        color: Color(0xFFFB6340),
                        height: 20,
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          "Update Laporan",
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
      detaillaporan();
    });
    showModalBottomSheet(
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
                        future: detaillaporan(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Laporan',
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
                                    'Deskripsi',
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
                                          snapshot.data['data']['deskripsi']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Tanggal Laporan',
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
                                          ['tanggal_laporan']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Bukti File Laporan',
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
                                          snapshot.data['data']['lampiran']),
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
                                          ['status_laporan']),
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
          'Laporan',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF5F72E4),
          ),
        ),
        actions: <Widget>[
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
                    builder: (BuildContext context) => AjukanLaporan(),
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
                    future: getLaporan(),
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
                                height: MediaQuery.of(context).size.height / 6,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      border: Border(
                                        left: BorderSide(
                                          width: 6.0,
                                          color: AppColor.primary,
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
                                            "${snapshot.data['data'][index]['deskripsi']}",
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
                                                      ['status_laporan'] ==
                                                  "Diterima") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_laporan']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.success,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                          [index]
                                                      ['status_laporan'] ==
                                                  "Ditolak") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_laporan']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.danger,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                          [index]
                                                      ['status_laporan'] ==
                                                  "Diproses") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_laporan']}",
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
                                                "Tanggal Laporan : ",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "${snapshot.data['data'][index]['tanggal_laporan']}",
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
                                                      ['status_laporan'] ==
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
                                                            UpdateLaporan(
                                                          uid: int.parse(
                                                              snapshot.data[
                                                                      'data'][
                                                                  index]['id']),
                                                          tgl: (snapshot.data[
                                                                  'data'][index]
                                                              [
                                                              'tanggal_laporan']),
                                                          deskripsi: (snapshot
                                                                      .data[
                                                                  'data'][index]
                                                              ['deskripsi']),
                                                          file: (snapshot.data[
                                                                  'data'][index]
                                                              ['lampiran']),
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
                                                    deletelaporan();
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
