import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hris_apps/style/color.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  late GoogleMapController mapController;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await Future.delayed(Duration(seconds: 3)); // Simulate loading

    if (mounted) {
      setState(() {
        /* ... */
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.77483, -122.419416),
              zoom: 12,
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
