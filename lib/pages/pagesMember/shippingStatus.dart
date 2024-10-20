import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/models/response/deliveryByDidGetResponse.dart';
import 'package:raidely/shared/appData.dart';

class ShippingstatusPage extends StatefulWidget {
  const ShippingstatusPage({super.key});

  @override
  State<ShippingstatusPage> createState() => _ShippingstatusPageState();
}

class _ShippingstatusPageState extends State<ShippingstatusPage> {
  late Future<void> loadData;
  late DeliveryByDidGetResponse listResultsResponeDeliveryByDid;
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  Polyline _polyline =
      const Polyline(polylineId: PolylineId('route'), points: []);

  LatLng? senderlocation;
  LatLng? itemlocation;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();

    // Listen to real-time updates from Firestore
    FirebaseFirestore.instance
        .collection('rider')
        .doc('test${context.read<Appdata>().didFileShippingStatus.did}')
        .snapshots()
        .listen((snapshot) {
      var data = snapshot.data();
      if (data != null) {
        List<String> latLngSender = data['gpsRider'].split(',');
        setState(() {
          senderlocation = LatLng(double.parse(latLngSender[0].trim()),
              double.parse(latLngSender[1].trim()));
          _addMarkerAndDrawRoute(); // Update map markers and routes
          _fetchRoute();
        });
      }
    });
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var apiKey = config['apiKey'];
    var did = context.read<Appdata>().didFileShippingStatus.did;

    // Fetch data from API
    var response = await http.get(Uri.parse('$url/delivery/$did'));
    listResultsResponeDeliveryByDid =
        deliveryByDidGetResponseFromJson(response.body);

    // Parse sender and receiver locations
    List<String> latLngReceiver =
        listResultsResponeDeliveryByDid.senderGps.split(',');

    itemlocation = LatLng(double.parse(latLngReceiver[0].trim()),
        double.parse(latLngReceiver[1].trim()));
    _fetchRoute();
    setState(() {});
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
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: SizedBox(
                width: width * 0.1,
                height: height * 0.05,
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: width * 0.01),
            Text(
              'สถานะการส่งสินค้า',
              style: TextStyle(
                fontSize: Get.textTheme.titleLarge!.fontSize,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _addMarkerAndDrawRoute();
                    },
                    initialCameraPosition: CameraPosition(
                      target: itemlocation!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    polylines: {_polyline},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addMarkerAndDrawRoute() {
    // Add Marker for start location
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: senderlocation!,
        infoWindow: const InfoWindow(
          title: 'จุดเริ่มต้น',
          snippet: 'รายละเอียดเกี่ยวกับจุดเริ่มต้น',
        ),
      ),
    );

    // Add Marker for end location
    _markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: itemlocation!,
        infoWindow: const InfoWindow(
          title: 'ปลายทาง',
          snippet: 'รายละเอียดเกี่ยวกับปลายทาง',
        ),
      ),
    );

    // Fetch directions from Google Directions API
    setState(() {});
  }

  void _fetchRoute() async {
    var config = await Configuration.getConfig();
    var apiKey = config['apiKey'];
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${senderlocation!.latitude},${senderlocation!.longitude}&destination=${itemlocation!.latitude},${itemlocation!.longitude}&key=$apiKey";

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      _createPolyline(data);
    } else {
      log('Failed to load directions');
    }
  }

  void _createPolyline(Map<String, dynamic> data) {
    // Check if routes are available
    if (data['routes'].isNotEmpty) {
      List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
      List<LatLng> polylinePoints = [];

      // Extract points from each step
      for (var step in steps) {
        String encodedPolyline = step['polyline']['points'];
        List<PointLatLng> decodedPoints =
            PolylinePoints().decodePolyline(encodedPolyline);
        polylinePoints.addAll(decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude)));
      }

      setState(() {
        _polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: polylinePoints,
        );
      });
    }
  }
}
