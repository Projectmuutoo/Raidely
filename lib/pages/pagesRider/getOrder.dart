import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneRiderGetResponse.dart';
import 'package:raidely/models/response/deliveryByDidGetResponse.dart';
import 'package:raidely/shared/appData.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GetorderPage extends StatefulWidget {
  const GetorderPage({super.key});

  @override
  State<GetorderPage> createState() => _GetorderPageState();
}

class _GetorderPageState extends State<GetorderPage> {
  late Future<void> loadData;
  late GoogleMapController mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Polyline _polyline =
      const Polyline(polylineId: PolylineId('route'), points: []);
  late DeliveryByDidGetResponse listResultsResponeDeliveryByDid;
  late LatLng riderlocation;
  late LatLng itemlocation;
  late LatLng senderlocation;
  late LatLng receiverlocation;
  LatLng currentRiderLocation = const LatLng(0.0, 0.0); // Default value
  StreamSubscription<Position>? positionStream;
  bool clickGetOrder = false;
  File? savedFile;
  XFile? image;
  ImagePicker picker = ImagePicker();
  Set<Marker> markers = {}; // Set ของ Marker
  bool displayRiderSender = true;
  bool displayRiderReceiver = true;
  bool isDelivered = false; // สถานะของการส่งสินค้า
  late List<ByPhoneRiderGetResponse> resultsResponseRiderBody = [];

  @override
  void initState() {
    late PolylinePoints polylinePoints;
    riderlocation = const LatLng(0.0, 0.0); // หรือค่าที่ต้องการ
    itemlocation = const LatLng(0.0, 0.0); // หรือค่าที่ต้องการ
    senderlocation = const LatLng(0.0, 0.0); // หรือค่าที่ต้องการ
    receiverlocation = const LatLng(0.0, 0.0); // หรือค่าที่ต้องการ
    loadData = loadDataAsync();
    var chick = context.read<Appdata>().didInTableDelivery.clickGetorder;
    if (chick) {
      setState(() {
        clickGetOrder = chick;
      });
    }
    var did = context.read<Appdata>().didInTableDelivery.did;
    FirebaseFirestore.instance
        .collection('rider')
        .doc('test${did}')
        .snapshots()
        .listen((snapshot) {
      var data = snapshot.data();
      if (data != null) {
        List<String> latLngSender = data['gpsRider'].split(',');
        setState(() {
          riderlocation = LatLng(double.parse(latLngSender[0].trim()),
              double.parse(latLngSender[1].trim()));
        });
        _addMarkerAndDrawRoute(); // Update map markers and routes
      }
    });

    super.initState();
  }

  Future<void> loadDataAsync() async {
    try {
      var config = await Configuration.getConfig();
      var url = config['apiEndpoint'].toString();
      var apiKey = config['apiKey'];
      var did = context.read<Appdata>().didInTableDelivery.did;
      var phone = context.read<Appdata>().loginKeepUsers.phone;
      var responseRider = await http.get(Uri.parse('$url/rider/$phone'));
      resultsResponseRiderBody =
          byPhoneRiderGetResponseFromJson(responseRider.body);
      await _getCurrentLocation(); // Get current location in real-time

      // Fetch delivery details from your API
      var response = await http.get(Uri.parse('$url/delivery/$did'));

      if (response.statusCode == 200) {
        listResultsResponeDeliveryByDid =
            deliveryByDidGetResponseFromJson(response.body);

        // Parse GPS coordinates of the sender and receiver
        if (listResultsResponeDeliveryByDid.senderGps != null &&
            listResultsResponeDeliveryByDid.receiverGps != null) {
          List<String> latLngSender =
              listResultsResponeDeliveryByDid.senderGps.split(',');
          List<String> latLngReceiver =
              listResultsResponeDeliveryByDid.receiverGps.split(',');

          // ตรวจสอบค่าของ Sender GPS ก่อนตั้งค่า
          if (listResultsResponeDeliveryByDid.senderGps != null) {
            double senderLatitude = double.parse(latLngSender[0].trim());
            double senderLongitude = double.parse(latLngSender[1].trim());
            senderlocation = LatLng(senderLatitude, senderLongitude);
          } else {
            log("Sender GPS data is null");
          }

          double receiverLatitude = double.parse(latLngReceiver[0].trim());
          double receiverLongitude = double.parse(latLngReceiver[1].trim());
          receiverlocation = LatLng(receiverLatitude, receiverLongitude);

          riderlocation = LatLng(
              currentRiderLocation.latitude, currentRiderLocation.longitude);

          // Call getOrder only if clickGetOrder is true
          if (clickGetOrder) {
            getOrder(listResultsResponeDeliveryByDid.did, 0);
            // updateStatusdelivery(listResultsResponeDeliveryByDid.did, 0);
          }

          // Call the direction method to draw the route
          _addMarkerAndDrawRoute();
        }
      } else {
        throw Exception(
            'Failed to fetch delivery data: ${response.statusCode}');
      }
    } catch (e) {
      log("Error loading data: $e");
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
                        },
                        initialCameraPosition: CameraPosition(
                          target: riderlocation!,
                          zoom: 14.0,
                        ),
                        markers: _markers,
                        polylines: _polylines // Add Polyline to Google Map
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical: height * 0.005,
                    ),
                    child: !clickGetOrder
                        ? Row(
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
                                                fontSize: Get.textTheme
                                                    .titleMedium?.fontSize,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              listResultsResponeDeliveryByDid
                                                  .senderName,
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium?.fontSize,
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
                                                        fontSize: Get
                                                            .textTheme
                                                            .titleMedium
                                                            ?.fontSize,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          listResultsResponeDeliveryByDid
                                                              .senderAddress,
                                                      style: TextStyle(
                                                        fontFamily: 'itim',
                                                        fontSize: Get
                                                            .textTheme
                                                            .titleMedium
                                                            ?.fontSize,
                                                        color: const Color(
                                                            0xff606060),
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
                                                fontSize: Get.textTheme
                                                    .titleMedium?.fontSize,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              listResultsResponeDeliveryByDid
                                                  .senderPhone,
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium?.fontSize,
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
                          )
                        : InkWell(
                            onTap: () {
                              final RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              final Offset offset =
                                  renderBox.localToGlobal(Offset.zero);

                              showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  offset.dy, // ตำแหน่ง x
                                  offset.dy +
                                      height *
                                          0.52, // ตำแหน่ง y หลังจาก `SizedBox`
                                  offset.dx,
                                  offset.dy,
                                ),
                                color: const Color.fromARGB(255, 203, 203, 203),
                                items: [
                                  PopupMenuItem(
                                    value: 'แกลลอรี่',
                                    child: Text(
                                      'เลือกจากแกลลอรี่',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'เลือกไฟล์',
                                    child: Text(
                                      'เลือกไฟล์',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'ถ่ายรูป',
                                    child: Text(
                                      'ถ่ายรูป',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ).then((value) async {
                                if (value != null) {
                                  if (value == 'แกลลอรี่') {
                                    image = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        savedFile = File(image!.path);
                                      });
                                    }
                                  } else if (value == 'เลือกไฟล์') {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      setState(() {
                                        savedFile =
                                            File(result.files.first.path!);
                                      });
                                    }
                                  } else if (value == 'ถ่ายรูป') {
                                    image = await picker.pickImage(
                                        source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {
                                        savedFile = File(image!.path);
                                      });
                                    }
                                  }
                                }
                              });
                            },
                            child: SizedBox(
                              width: width * 0.35,
                              height: height * 0.1,
                              child: DottedBorder(
                                color: Colors.black, // สีของเส้นขอบ
                                strokeWidth: 1,
                                dashPattern: const [5, 5],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                child: savedFile == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                children: [
                                                  // Container for the outer circle
                                                  Container(
                                                    height: height * 0.08,
                                                    width: width * 0.08,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xffd9d9d9),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          // White inner circle
                                                          Container(
                                                            height:
                                                                height * 0.08,
                                                            width: width * 0.08,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          // Inner gray circle
                                                          Container(
                                                            height:
                                                                height * 0.06,
                                                            width: width * 0.06,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffd9d9d9),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          // SVG Icon
                                                          SvgPicture.string(
                                                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                                            height:
                                                                height * 0.02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: Text(
                                                      'แนบรูปสินค้า',
                                                      style: TextStyle(
                                                        fontSize: Get
                                                            .textTheme
                                                            .titleMedium!
                                                            .fontSize,
                                                        color: Color(
                                                          int.parse(
                                                              '0xff898989'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.file(
                                                savedFile!,
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: height * -0.01,
                                            right: width * 0.01,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: height * 0.08,
                                                      width: width * 0.08,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xffd9d9d9),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // White inner circle
                                                            Container(
                                                              height:
                                                                  height * 0.08,
                                                              width:
                                                                  width * 0.08,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            // Inner gray circle
                                                            Container(
                                                              height:
                                                                  height * 0.06,
                                                              width:
                                                                  width * 0.06,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffd9d9d9),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            // SVG Icon
                                                            SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                                              height:
                                                                  height * 0.02,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                  ),
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================
                  //=================================================================================================

                  if (!clickGetOrder)
                    //กดรายละเอียดมา
                    ElevatedButton(
                      onPressed: () {
                        getOrder(listResultsResponeDeliveryByDid.did, 0);
                        updateStatusdelivery(
                            listResultsResponeDeliveryByDid.did, 0);
                      },
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
                  if (clickGetOrder)
                    // กดรับออเดอร์มา
                    ElevatedButton(
                      onPressed: () {
                        // เช็คสถานะและอัปเดตค่าให้เหมาะสม
                        if (isDelivered) {
                          // ถ้าสถานะเป็นส่งสินค้าสำเร็จแล้ว เปลี่ยนกลับเป็น false
                          setState(() {
                            isDelivered = false; // เปลี่ยนสถานะเป็น false
                          });
                          updateStatusdelivery(
                              listResultsResponeDeliveryByDid.did,
                              3); // เปลี่ยนสถานะส่งสินค้ากลับ (หรือสถานะที่ต้องการ)
                        } else {
                          // ถ้ายังไม่ส่งสินค้าให้ทำการรับสินค้า
                          getOrder(listResultsResponeDeliveryByDid.did,
                              1); // ส่งค่า 1
                          updateStatusdelivery(
                              listResultsResponeDeliveryByDid.did, 1);
                          setState(() {
                            isDelivered = true; // เปลี่ยนสถานะเมื่อกดปุ่ม
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          width * 0.4,
                          height * 0.05,
                        ),
                        backgroundColor: const Color(0xffD5843D),
                        elevation: 3, // เงาล่าง
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24), // มุมโค้งมน
                        ),
                      ),
                      child: Text(
                        isDelivered
                            ? "ส่งสินค้าสำเร็จ"
                            : "รับสินค้าแล้ว", // เปลี่ยนข้อความตามสถานะ
                        style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
                //=================================================================================================
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    //ปิดหน้าจอ=หยุดรับตำแหน่งrider
    stopLocationUpdates(); // Stop location updates when the page is disposed
    mapController.dispose(); // Dispose of the map controller
    super.dispose();
  }

  void getOrder(int value, int display) {
    setState(() {
      clickGetOrder = true;
      displayRiderSender = (display == 0);
      displayRiderReceiver = (display == 1);
      log("$display");
    });
    _addMarkerAndDrawRoute();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Ensure permission is granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        currentRiderLocation = LatLng(position.latitude, position.longitude);
        updatelocation(currentRiderLocation);
        log("Current Location - latitude: ${currentRiderLocation.latitude}, longitude: ${currentRiderLocation.longitude}");
      });
    } catch (e) {
      log("Error getting current location: $e");
    }
  }

  void stopLocationUpdates() {
    // Stop listening to location updates when not needed
    positionStream?.cancel();
  }

  Future<void> _addMarkerAndDrawRoute() async {
    // ลบมาร์กเกอร์ที่มีอยู่ก่อนหน้านี้
    _markers.clear();

    // แสดงมาร์กเกอร์สำหรับ Rider
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: riderlocation!,
        infoWindow: const InfoWindow(
          title: 'Rider',
          snippet: 'รายละเอียดเกี่ยวกับจุดเริ่มต้น',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    if (displayRiderSender) {
      _markers.add(
        Marker(
          markerId: const MarkerId('sender'),
          position: senderlocation!,
          infoWindow: const InfoWindow(
            title: 'Sender',
            snippet: 'รายละเอียดเกี่ยวกับปลายทาง',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (displayRiderReceiver) {
      _markers.add(
        Marker(
          markerId: const MarkerId('receiver'),
          position: receiverlocation!,
          infoWindow: const InfoWindow(
            title: 'Receiver',
            snippet: 'รายละเอียดเกี่ยวกับปลายทาง',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {
      // อัปเดตแผนที่เมื่อเพิ่มมาร์กเกอร์และเส้นทาง
    });
  }

  Future<void> updatelocation(LatLng currentRiderLocation) async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var db = FirebaseFirestore.instance;
    var data = {
      'gpsRider':
          '${currentRiderLocation.latitude},${currentRiderLocation.longitude}',
      'did': context.read<Appdata>().didInTableDelivery.did,
      'status': 'ไรเดอร์รับออเดอร์แล้ว'
    };

    db
        .collection('rider')
        .doc('test${context.read<Appdata>().didInTableDelivery.did}')
        .set(data);
  }

  Future<void> updateStatusdelivery(int did, int i) async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();

    //=================================
    //=================================
    //=================================
    //ตัวแปรภาพ
    //=================================
    //=================================
    //=================================

    if (i == 0) {
      // log("update รับออเดอร์");
      // log(isDelivered.toString());
      var responseCheckorders = await http.get(
        Uri.parse("$url/delivery/check-order/$did"),
        headers: {"Content-Type": "application/json"},
      );

      if (responseCheckorders.statusCode == 404) {
        // No pending orders found
        log('No pending orders found for delivery ID: $did');
        log('Response body: ${responseCheckorders.body}'); // Log the response body
        return; // Stop execution if no orders are found
      }

      var json = {"status": "ไรเดอร์เข้ารับสินค้าแล้ว"};
      var responsePutJsonUpdateMember = await http.put(
        Uri.parse("$url/delivery/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(json),
      );
      var responsePutJsonUpdateRider_Assign = await http.put(
        Uri.parse("$url/rider_assigns/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(json),
      );
      var riderId = resultsResponseRiderBody[0].rid;
      var jsonriderass = {
        'delivery_id': did,
        'rider_id': riderId,
        'status': "ไรเดอร์เข้ารับสินค้าแล้ว",
        'image_receiver': '-',
        'image_success': '-'
      };

      var jsonencode = jsonEncode(jsonriderass);

      var responsePostJsonRiderass = await http.post(
        Uri.parse("$url/rider_assigns/insert"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonencode, // Use the encoded JSON string directly
      );

      if (responsePostJsonRiderass.statusCode == 200) {
        // Pass the value to GetorderPage
        log('เข้าอันนี้ละ2');
      } else {
        log("can't receive order");
      }
    } else if (i == 1) {
      // log("update รับสินค้าแล้ว");
      // log(isDelivered.toString());
      log('เข้า i=1');
      var jsondelivery = {
        "status": "ไรเดอร์กำลังนำส่งสินค้า",
        "rider_receive": "ตัวแปรภาพ"
      };
      var jsonriderass = {
        "status": "ไรเดอร์กำลังนำส่งสินค้า",
        "image_receiver": "ตัวแปรภาพ"
      };
      var responsePutJsonUpdateMember = await http.put(
        Uri.parse("$url/delivery/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(jsondelivery),
      );
      var responsePutJsonUpdateRider_Assign = await http.put(
        Uri.parse("$url/rider_assigns/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(jsonriderass),
      );
    } else {
      log('เข้า else');
      // log("update ส่งสินค้าสำเร็จ");
      // log(isDelivered.toString());
      var jsondelivery = {
        "status": "ส่งสินค้าสำเร็จ",
        "rider_success": "ตัวแปรภาพ"
      };
      var jsonriderass = {
        "status": "ส่งสินค้าสำเร็จ",
        "image_success": "ตัวแปรภาพ"
      };
      var responsePutJsonUpdateMember = await http.put(
        Uri.parse("$url/delivery/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(jsondelivery),
      );
      var responsePutJsonUpdateRider_Assign = await http.put(
        Uri.parse("$url/rider_assigns/update/$did"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(jsonriderass),
      );

      // แสดง Popup หลังจากอัปเดตข้อมูลสำเร็จ
      Get.dialog(
        AlertDialog(
          title: const Text("สำเร็จ"),
          content: const Text("ส่งข้อมูลสำเร็จ"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // ปิด Popup
                Get.back(); // กลับไปหน้าจอหลัก
              },
              child: const Text("ตกลง"),
            ),
          ],
        ),
      );
    }
  }
}
