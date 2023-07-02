import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DetPresensi extends StatefulWidget {
  const DetPresensi({super.key});

  @override
  State<DetPresensi> createState() => _DetPresensiState();
}

class _DetPresensiState extends State<DetPresensi> {
  bool _isLoading = true;
  double latmasuk = 0;
  double lonmasuk = 0;
  double latpulang = 0;
  double lonpulang = 0;
  int _counter = 0;
  int _selectedIndex = 1;
  Map simpanmasuk = {};
  Map simpanpulang = {};

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _setTime() {
    print('Set Time');
  }

  void _addTime() {
    print('ADD TIME');
  }

  void itemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initState() {
    getAbsen();
    presenmasuk();
    presenpulang();
    super.initState();
  }

  Future getAbsen() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token =
        await localStorage.getString("token").toString().replaceAll('"', '');

    final response =
        await http.get(Uri.parse(baseURL + 'getmobileabsen'), headers: {
      'Content-Type': 'application/json; Charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    var user = json.decode(response.body);
    if (user == null) {
      print('null');
    } else {
      if (user['data']['latmasuk'] != null &&
          user['data']['lonmasuk'] != null) {
        latmasuk = double.parse(user['data']['latmasuk']);
        lonmasuk = double.parse(user['data']['lonmasuk']);
      }
      if (user['data']['latpulang'] != null &&
          user['data']['lonpulang'] != null) {
        latpulang = double.parse(user['data']['latpulang']);
        lonpulang = double.parse(user['data']['lonpulang']);
      } else {
        print('hahahah');
      }
    }

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
      return user;
    }
  }

  final Set<Marker> markers = new Set(); //markers for google map
  Set<Marker> getmarkers() {
    //markers to place on map

    markers.add(Marker(
      //add first marker
      markerId: MarkerId("Presensi Masuk"),
      position: LatLng(latmasuk, lonmasuk), //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Presensi Masuk',
        snippet: 'Lokasi Presensi Masuk',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker(
      //add second marker
      markerId: MarkerId("Presensi Pulang"),
      position: LatLng(latpulang, lonpulang), //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Presensi Pulang ',
        snippet: 'Lokasi Presensi Pulang',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    //add more markers here

    return markers;
  }

  // Future<void> _onMapCreated(GoogleMapController controller) async {
  //   _controller.complete(controller);
  // }

  getaddress() async {
    if (latmasuk == 0 || lonmasuk == 0) {
      print('tes');
    } else {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latmasuk, lonmasuk);
      Placemark alamat = placemarks[0];
      simpanmasuk = {
        'Kota': alamat.subAdministrativeArea,
        'Kode Pos': alamat.postalCode,
        'Kecamatan': alamat.locality,
        'Desa': alamat.subLocality,
        'Jalan': alamat.street
      };
      setState(() {
        _isLoading = true;
      });
    }
  }

  getaddresspul() async {
    if (latpulang == 0 || lonpulang == 0) {
      print('tes');
    } else {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latpulang, lonpulang);
      Placemark alamatpul = placemarks[0];
      simpanpulang = {
        'Kota': alamatpul.subAdministrativeArea,
        'Kode Pos': alamatpul.postalCode,
        'Kecamatan': alamatpul.locality,
        'Desa': alamatpul.subLocality,
        'Jalan': alamatpul.street
      };
      setState(() {
        _isLoading = true;
      });
    }
  }

  presenmasuk() async {
    Future.delayed(Duration(seconds: 3), () {
      getaddress();
    });
    setState(() {
      _isLoading = false;
    });
    return simpanmasuk;
  }

  presenpulang() async {
    Future.delayed(Duration(seconds: 3), () {
      getaddresspul();
    });
    setState(() {
      _isLoading = false;
    });
    return simpanpulang;
  }

  Completer<GoogleMapController> _controller = Completer();
  bool _isMapLoading = true;
  late GoogleMapController mapController;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await Future.delayed(Duration(seconds: 6)); // Simulate loading

    if (mounted) {
      setState(() {
        /* ... */
        _isMapLoading = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  final LatLngBounds bounds = LatLngBounds(
    southwest: LatLng(-6.3428, 106.8781),
    northeast: LatLng(-6.1148, 107.1989),
  );
  @override
  Widget build(BuildContext context) {
    final deviceRatio = 4 / 3;

    Future<void> masuk() async {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latmasuk, lonmasuk), zoom: 19)));
    }

    Future<void> pulang() async {
      if (latpulang == 0) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnColor: AppColor.danger,
          title: 'Belum Presensi',
          text: 'Tidak Dapat Menemukan Lokasi',
        );
      } else {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(latpulang, lonpulang),
          zoom: 19,
        )));
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: false,
                  leadingWidth: 22,
                  automaticallyImplyLeading: true,
                  title: Text(
                    'Detail Presensi',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF5F72E4),
                    ),
                  ),
                  actions: <Widget>[], //<Widget>[]
                  backgroundColor: Colors.white,
                  bottom: TabBar(indicatorColor: AppColor.primary, tabs: [
                    Tab(
                      child: Text(
                        'Lokasi Presensi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Detail Foto',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ]),
                ),
                body: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      FutureBuilder(
                          future: getAbsen(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            }
                            if (snapshot.data['data']['latmasuk'] == null) {
                              return Center(
                                child: Text('Belum Presensi'),
                              );
                            } else {
                              return Container(
                                child: SlidingUpPanel(
                                  minHeight:
                                      MediaQuery.of(context).size.height / 10,
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 2.6,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  panel: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              80,
                                        ),
                                        Center(
                                          child: Icon(
                                            Icons.keyboard_arrow_up,
                                            color: AppColor.darkgrey,
                                            size: 30,
                                          ),
                                        ),
                                        Center(
                                            child: Text(
                                          'Detail Lokasi',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        )),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              28,
                                        ),
                                        if (_isLoading == false) ...[
                                          Container(
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()))
                                        ] else if (_isLoading == true) ...[
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Lokasi Presensi Masuk',
                                                  style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                if (simpanmasuk == {}) ...[
                                                  Text(
                                                    'Belum Melakukan Presensi',
                                                    style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ] else if (simpanmasuk !=
                                                    {}) ...[
                                                  Text(
                                                    'Absen Masuk : ${snapshot.data['data']['jam_masuk']}',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${(simpanmasuk).toString().replaceAll('{', '').replaceAll('}', '')}',
                                                    style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      28,
                                                ),
                                                Text(
                                                  'Lokasi Presensi Pulang',
                                                  style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                if (snapshot.data['data']
                                                        ['latpulang'] ==
                                                    null) ...[
                                                  Text(
                                                    'Belum Presensi',
                                                    style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ] else if (snapshot.data['data']
                                                        ['latpulang'] !=
                                                    null) ...[
                                                  Text(
                                                    'Absen Pulang : ${snapshot.data['data']['jam_pulang']}',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '${(simpanpulang).toString().replaceAll('{', '').replaceAll('}', '')}',
                                                    style: TextStyle(
                                                      color: AppColor.darkgrey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                  body: Stack(
                                    children: [
                                      GoogleMap(
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              double.parse(snapshot.data['data']
                                                  ['latmasuk']),
                                              double.parse(snapshot.data['data']
                                                  ['lonmasuk'])),
                                          zoom: 15,
                                        ),
                                        markers: getmarkers(),
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          // add your floating action button
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20, right: 10),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: 38,
                                                  height: 38,
                                                  child: FloatingActionButton(
                                                    heroTag: 'masuk',
                                                    backgroundColor:
                                                        AppColor.primary,
                                                    onPressed: masuk,
                                                    child: Icon(
                                                      Icons.login_outlined,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                SizedBox(
                                                  height: 38,
                                                  width: 38,
                                                  child: FloatingActionButton(
                                                    heroTag: 'pulang',
                                                    backgroundColor:
                                                        AppColor.warning,
                                                    onPressed: pulang,
                                                    child: Icon(
                                                      Icons.logout_outlined,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      if (_isMapLoading)
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  5.8),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                    ],
                                  ),
                                  // body: FutureBuilder(
                                  //   future: Future.delayed(Duration(
                                  //       seconds:
                                  //           2)), // contoh Future yang berisi loading data dari sumber eksternal
                                  //   builder: (BuildContext context,
                                  //       AsyncSnapshot snapshot) {
                                  //     if (snapshot.connectionState ==
                                  //         ConnectionState.waiting) {
                                  //       // Menampilkan widget loading ketika Future masih dalam proses
                                  //       return Container(
                                  //           margin: EdgeInsets.only(
                                  //               bottom: MediaQuery.of(context)
                                  //                       .size
                                  //                       .height /
                                  //                   5),
                                  //           child: Center(
                                  //               child:
                                  //                   CircularProgressIndicator()));
                                  //     } else {
                                  //       return FutureBuilder(
                                  //           future: getAbsen(),
                                  //           builder: (context, snapshot) {
                                  //             if (snapshot.data == null) {
                                  //               return Text('');
                                  //             } else {
                                  //               return Scaffold(
                                  //                 body: Stack(children: [
                                  //                   GoogleMap(
                                  //                     mapType: MapType.normal,
                                  //                     initialCameraPosition:
                                  //                         CameraPosition(
                                  //                       target: LatLng(
                                  //                           double.parse(snapshot
                                  //                                       .data[
                                  //                                   'data']
                                  //                               ['latmasuk']),
                                  //                           double.parse(snapshot
                                  //                                       .data[
                                  //                                   'data']
                                  //                               ['lonmasuk'])),
                                  //                       zoom: 17,
                                  //                     ),
                                  //                     markers: getmarkers(),
                                  //                     onMapCreated:
                                  //                         (GoogleMapController
                                  //                             controller) {
                                  //                       if (!_controller
                                  //                           .isCompleted) {
                                  //                         //first calling is false
                                  //                         //call "completer()"
                                  //                         _controller.complete(
                                  //                             controller);
                                  //                       } else {
                                  //                         print('');
                                  //                         //other calling, later is true,
                                  //                         //don't call again completer()
                                  //                       }
                                  //                     },
                                  //                   ),
                                  //                   Align(
                                  //                       alignment:
                                  //                           Alignment.topRight,
                                  //                       // add your floating action button
                                  //                       child: Padding(
                                  //                         padding:
                                  //                             const EdgeInsets
                                  //                                     .only(
                                  //                                 top: 20,
                                  //                                 right: 10),
                                  //                         child: Column(
                                  //                           children: [
                                  //                             SizedBox(
                                  //                               width: 38,
                                  //                               height: 38,
                                  //                               child:
                                  //                                   FloatingActionButton(
                                  //                                 heroTag:
                                  //                                     'masuk',
                                  //                                 backgroundColor:
                                  //                                     AppColor
                                  //                                         .primary,
                                  //                                 onPressed:
                                  //                                     masuk,
                                  //                                 child: Icon(
                                  //                                   Icons
                                  //                                       .login_outlined,
                                  //                                   size: 18,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                             SizedBox(
                                  //                               height: 8,
                                  //                             ),
                                  //                             SizedBox(
                                  //                               height: 38,
                                  //                               width: 38,
                                  //                               child:
                                  //                                   FloatingActionButton(
                                  //                                 heroTag:
                                  //                                     'pulang',
                                  //                                 backgroundColor:
                                  //                                     AppColor
                                  //                                         .warning,
                                  //                                 onPressed:
                                  //                                     pulang,
                                  //                                 child: Icon(
                                  //                                   Icons
                                  //                                       .logout_outlined,
                                  //                                   size: 18,
                                  //                                 ),
                                  //                               ),
                                  //                             ),
                                  //                           ],
                                  //                         ),
                                  //                       )),
                                  //                 ]),
                                  //               );
                                  //             }
                                  //           });
                                  //     }
                                  //   },
                                  // ),
                                  // body: Container(
                                  //   child: GoogleMap(
                                  //     zoomGesturesEnabled: true,
                                  //     initialCameraPosition: CameraPosition(
                                  //       target: LatLng(
                                  //           double.parse(snapshot.data['data']
                                  //               ['latmasuk']),
                                  //           double.parse(snapshot.data['data']
                                  //               ['lonmasuk'])),
                                  //       zoom: 17,
                                  //     ),
                                  //     onMapCreated: _onMapCreated,
                                  //     markers: getmarkers(),
                                  //   ),
                                  // )
                                ),
                              );
                            }
                          }),
                      FutureBuilder(
                          future: getAbsen(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            } else {
                              return SingleChildScrollView(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.2,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                30,
                                      ),
                                      Text(
                                        'Detail Presensi Masuk',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColor.darkgrey,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                      ),
                                      if (snapshot.data['data']
                                              ['selfie_masuk'] ==
                                          null) ...[
                                        Center(
                                          child: Text('Belum Presensi'),
                                        )
                                      ] else if (snapshot.data['data']
                                              ['selfie_masuk'] !=
                                          null) ...[
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 58),
                                            child: Transform.scale(
                                              scale: deviceRatio,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                                child: AspectRatio(
                                                  aspectRatio: 4 / 3,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      'https://prisen.online/upload/${snapshot.data['data']['selfie_masuk']}',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                17,
                                      ),
                                      Text(
                                        'Detail Presensi Pulang',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColor.darkgrey,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                      ),
                                      if (snapshot.data['data']
                                              ['selfie_pulang'] ==
                                          null) ...[
                                        Center(
                                          child: Text('Belum Presensi'),
                                        )
                                      ] else if (snapshot.data['data']
                                              ['selfie_pulang'] !=
                                          null) ...[
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 58),
                                            child: Transform.scale(
                                              scale: deviceRatio,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                                child: AspectRatio(
                                                  aspectRatio: 4 / 3,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      'https://prisen.online/upload/${snapshot.data['data']['selfie_pulang']}',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                    ]))));
  }
}
