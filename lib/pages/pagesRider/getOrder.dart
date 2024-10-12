import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/deliveryByDidGetResponse.dart';
import 'package:raidely/shared/appData.dart';
import 'package:geolocator/geolocator.dart';

class GetorderPage extends StatefulWidget {
  const GetorderPage({super.key});

  @override
  State<GetorderPage> createState() => _GetorderPageState();
}

class _GetorderPageState extends State<GetorderPage> {
  late Future<void> loadData;
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  Polyline _polyline =
      const Polyline(polylineId: PolylineId('route'), points: []);
  late DeliveryByDidGetResponse listResultsResponeDeliveryByDid;
  late LatLng Riderlocation;
  late LatLng Itemlocation;
  late LatLng currentRiderLocation;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
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
              'รายละเอียด',
              style: TextStyle(
                fontSize: Get.textTheme.titleLarge?.fontSize,
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
                  SizedBox(
                    height: height * 0.7, // 70% of the screen height
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        _addMarkerAndDrawRoute();
                      },
                      initialCameraPosition: CameraPosition(
                        target: Riderlocation,
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      polylines: {_polyline}, // Add Polyline to Google Map
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical: height * 0.005,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: width * 0.7,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'ชื่อผู้ส่ง: ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium?.fontSize,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        listResultsResponeDeliveryByDid
                                            .senderName,
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium?.fontSize,
                                          color: const Color(0xff606060),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Row(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: width * 0.65,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'ที่อยู่ผู้ส่ง: ',
                                                style: TextStyle(
                                                  fontFamily: 'itim',
                                                  fontSize: Get.textTheme
                                                      .titleMedium?.fontSize,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    listResultsResponeDeliveryByDid
                                                        .senderAddress,
                                                style: TextStyle(
                                                  fontFamily: 'itim',
                                                  fontSize: Get.textTheme
                                                      .titleMedium?.fontSize,
                                                  color:
                                                      const Color(0xff606060),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Row(
                                    children: [
                                      Text(
                                        'เบอร์โทรผู้ส่ง: ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium?.fontSize,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        listResultsResponeDeliveryByDid
                                            .senderPhone,
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium?.fontSize,
                                          color: const Color(0xff606060),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: width * 0.25,
                              child: Image.asset(
                                'assets/images/red.png',
                                height: height * 0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        width * 0.4,
                        height * 0.05,
                      ),
                      backgroundColor: const Color(0xff1EAC81),
                      elevation: 3, //เงาล่าง
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // มุมโค้งมน
                      ),
                    ),
                    child: Text(
                      "รับออเดอร์นี้",
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var apiKey = config['apiKey'];
    var did = context.read<Appdata>().didInTableDelivery.did;

    await _getCurrentLocation();

    // เรียกข้อมูลจาก API
    var response = await http.get(Uri.parse('$url/delivery/$did'));
    listResultsResponeDeliveryByDid =
        deliveryByDidGetResponseFromJson(response.body);

    // แยกพิกัดจากข้อมูล sender
    List<String> latLngSender =
        listResultsResponeDeliveryByDid.senderGps.split(',');
    List<String> latLngReceiver =
        listResultsResponeDeliveryByDid.receiverGps.split(',');

    // แปลงค่าของ sender
    double senderLatitude = double.parse(latLngSender[0].trim());
    double senderLongitude = double.parse(latLngSender[1].trim());
    LatLng senderLocation = LatLng(senderLatitude, senderLongitude);
    log("Sender - latitude: $senderLatitude, longitude: $senderLongitude");

    // แปลงค่าของ receiver
    double receiverLatitude = double.parse(latLngReceiver[0].trim());
    double receiverLongitude = double.parse(latLngReceiver[1].trim());
    LatLng receiverLocation = LatLng(receiverLatitude, receiverLongitude);
    log("Receiver - latitude: $receiverLatitude, longitude: $receiverLongitude");

    // กำหนดพิกัดปลายทาง
    Riderlocation =
        LatLng(currentRiderLocation.latitude, currentRiderLocation.longitude);

    if (response.statusCode == 200) {
      // เรียก Google Directions API และส่งค่า currentRiderLocation, senderLocation, receiverLocation ไป
      await direction(
          apiKey, currentRiderLocation, senderLocation, receiverLocation);
    }
  }

  Future<void> direction(String apiKey, LatLng riderLocation,
      LatLng senderLocation, LatLng receiverLocation) async {
    // ใช้พิกัด currentRiderLocation (riderLocation) ที่ได้รับมา, sender และ receiver
    final responseGoogleapis = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${riderLocation.latitude},${riderLocation.longitude}&destination=${receiverLocation.latitude},${receiverLocation.longitude}&waypoints=${senderLocation.latitude},${senderLocation.longitude}&key=$apiKey',
    ));

    if (responseGoogleapis.statusCode == 200) {
      final data = jsonDecode(responseGoogleapis.body);
      _createPolyline(data); // สร้างเส้นทางบนแผนที่
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentRiderLocation = LatLng(position.latitude, position.longitude);
      log("Current Location - latitude: ${currentRiderLocation.latitude}, longitude: ${currentRiderLocation.longitude}");
    } catch (e) {
      log("Error getting current location: $e");
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

  void _addMarkerAndDrawRoute() {
    // Add Marker for start location
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: Riderlocation,
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
        position: Itemlocation,
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
