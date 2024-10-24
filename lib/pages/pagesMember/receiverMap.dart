import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ReceiverMapPage extends StatefulWidget {
  final int mid; // Define mid as a final variable to hold the passed value

  const ReceiverMapPage(this.mid, {super.key});

  @override
  State<ReceiverMapPage> createState() => _ReceiverMapPageState();
}

class _ReceiverMapPageState extends State<ReceiverMapPage> {
  String? errorMessage;
  var db = FirebaseFirestore.instance;
  Set<Marker> markers = {};
  late GoogleMapController mapController;
  late StreamSubscription riderSubscription;
  bool isListening = false;
  bool isLoading = true;

  final LatLng startingPoint = LatLng(16.234368, 103.261975);

  @override
  void initState() {
    super.initState();
    _updateUserLocation(); // Fetch user's current location
    loadDataAsync(); // Load data when the widget initializes

    markers.add(
      Marker(
        markerId: MarkerId('currentLocation'),
        position: startingPoint,
        infoWindow: InfoWindow(title: 'Iam here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );

    log('Markers: ${markers.length}'); // Confirm marker addition
  }

  @override
  void dispose() {
    if (isListening) {
      riderSubscription.cancel(); // Cancel subscription on dispose
    }
    super.dispose();
  }

  Future<void> loadDataAsync() async {
    try {
      if (!isListening) {
        readDataRiderInRealTime();
        isListening = true;
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      log('Error fetching data: $errorMessage');
    }
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: userLocation,
            infoWindow: InfoWindow(title: 'Rider'),
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user location: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'รายการส่งสินค้า',
          style: TextStyle(
            fontSize: Get.textTheme.headlineSmall!.fontSize,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
                child: Text(
              'Error: $errorMessage',
              style: TextStyle(color: Colors.red),
            ))
          else
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                mapController.moveCamera(
                  CameraUpdate.newLatLng(startingPoint),
                );
              },
              initialCameraPosition: CameraPosition(
                target: startingPoint,
                zoom: 14,
              ),
              markers: markers,
            ),
          Positioned(
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(width * 0.4, height * 0.05),
                backgroundColor: const Color(0xffD5843D),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                "ย้อนกลับ", // "Back" in Thai
                style: TextStyle(
                  fontSize: Get.textTheme.titleLarge!.fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void readDataRiderInRealTime() {
    riderSubscription = db
        .collection('riderGetOrder')
        .where('riderId', isEqualTo: widget.mid) // Use widget.mid
        .snapshots()
        .listen((snapshot) {
      markers.removeWhere((marker) =>
          marker.markerId.value.startsWith('rider_')); // Remove rider markers

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String gpsRider = data['gpsRider'];
        var riderstatus = data['status'];

        List<String> latLng = gpsRider.split(',');
        if (latLng.length == 2) {
          double latitude = double.parse(latLng[0]);
          double longitude = double.parse(latLng[1]);
          LatLng riderLocation = LatLng(latitude, longitude);

          markers.add(
            Marker(
              markerId: MarkerId('rider_${doc.id}'),
              position: riderLocation,
              infoWindow: InfoWindow(title: '$riderstatus'),
            ),
          );
        }
      }

      setState(() {}); // Trigger UI update with new markers
      log("Markers updated.");
    });
  }
}
