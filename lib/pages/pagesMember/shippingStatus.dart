import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  // Declare as nullable and check later
  LatLng? senderlocation;
  LatLng? itemlocation;
  late LatLng currentRiderLocation;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
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
    List<String> latLngSender =
        listResultsResponeDeliveryByDid.senderGps.split(',');
    List<String> latLngReceiver =
        listResultsResponeDeliveryByDid.receiverGps.split(',');

    // Set sender and receiver locations
    senderlocation = LatLng(double.parse(latLngSender[0].trim()),
        double.parse(latLngSender[1].trim()));
    itemlocation = LatLng(double.parse(latLngReceiver[0].trim()),
        double.parse(latLngReceiver[1].trim()));

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
        position: senderlocation!, // Use non-nullable senderlocation
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
        position: itemlocation!, // Use non-nullable itemlocation
        infoWindow: const InfoWindow(
          title: 'ปลายทาง',
          snippet: 'รายละเอียดเกี่ยวกับปลายทาง',
        ),
      ),
    );

    setState(() {
      // Update the map when adding markers
    });
  }
}
