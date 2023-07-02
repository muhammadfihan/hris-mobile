import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hris_apps/style/color.dart';
import 'package:hris_apps/view/reqabsen/buatreq.dart';
import 'package:hris_apps/view/reqabsen/updatereq.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

import '../../api/globals.dart';
import '../login.dart';

class ReqAbsen extends StatefulWidget {
  const ReqAbsen({super.key});

  @override
  State<ReqAbsen> createState() => _ReqAbsenState();
}

class _ReqAbsenState extends State<ReqAbsen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScrollController _controller = new ScrollController();
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

  File? filePickerVal;
  File? filePickerValupdt;
  void initState() {
    TanggalReq.text = "";
    tanggalrequpdt.text = "";
    super.initState();
  }

  Future refresh() async {
    setState(() {
      getReq();
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
        'POST', Uri.parse(baseURL + 'updatereqabsenmobile/${id}'));
    request.headers.addAll(headers);
    request.fields['alasan'] = alasanupdt.text;
    request.fields['tanggal_req'] = tanggalrequpdt.text;
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
          text: 'Anda Telah Mengupdate Request Attendance',
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
                        'Pengajuan Request Attendance',
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
                          controller: Alasan,
                          onSaved: (String? val) {
                            Alasan.text = val!;
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
                        'Pilih Tanggal',
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
                                popupProps: PopupProps.dialog(
                                  fit: FlexFit.loose,
                                  dialogProps: DialogProps(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
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
                                          top: 5,
                                          left: 6,
                                          right: 6,
                                          bottom: 0)),
                                ),
                                onChanged: (tanggal) {
                                  TanggalReq.text = tanggal!;
                                },
                              ),
                            )),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Upload Bukti',
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
                                  hintText: "Upload BUkti Pendukung",
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
                          ajukanreq();
                        },
                        color: Color(0xFFFB6340),
                        height: 20,
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          "Ajukan Request",
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
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
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
                                          top: 5,
                                          left: 6,
                                          right: 6,
                                          bottom: 0)),
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
            ));
  }

  void _detail(BuildContext ctx) {
    setState(() {
      detailreq();
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
                        future: detailreq(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Pengajuan Request Attendance',
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
                                      child:
                                          Text(snapshot.data['data']['alasan']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Tanggal Request Attendance',
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
                                          snapshot.data['data']['tanggal_req']),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    'Bukti Pendukung',
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
                                          ['bukti_pendukung']),
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
                                      child: Text(
                                          snapshot.data['data']['status_req']),
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
          'Request Attendance',
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
                title: 'Request Attendance',
                text:
                    'Anda dapat melakukan pengajuan presensi jika anda lupa melakukan presensi, namun perlu diingat bahwa pengajuan ini harus menyertakan bukti valid tentang presensi dimana anda lupa',
              );
            },
          ), //IIcon
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
                    builder: (BuildContext context) => BuatReq(),
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
                    future: getReq(),
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
                                    MediaQuery.of(context).size.height / 6.1,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      border: Border(
                                        left: BorderSide(
                                          width: 6.0,
                                          color: Color(0xFF0FCDEF),
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
                                            "${snapshot.data['data'][index]['alasan']}",
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
                                                      ['status_req'] ==
                                                  "Diterima") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_req']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.success,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                      [index]['status_req'] ==
                                                  "Ditolak") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_req']}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColor.danger,
                                                  ),
                                                ),
                                              ] else if (snapshot.data['data']
                                                      [index]['status_req'] ==
                                                  "Diproses") ...[
                                                Text(
                                                  "${snapshot.data['data'][index]['status_req']}",
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
                                                "Tanggal : ",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "${snapshot.data['data'][index]['tanggal_req']}",
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
                                                      ['status_req'] ==
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
                                                            UpdateReq(
                                                          uid: int.parse(
                                                              snapshot.data[
                                                                      'data'][
                                                                  index]['id']),
                                                          tgl: (snapshot.data[
                                                                  'data'][index]
                                                              ['tanggal_req']),
                                                          alasan: (snapshot
                                                                  .data['data'][
                                                              index]['alasan']),
                                                          file: (snapshot.data[
                                                                  'data'][index]
                                                              [
                                                              'bukti_pendukung']),
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
                                                    deletereq();
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
                                            ], //<Widgt>[]
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
