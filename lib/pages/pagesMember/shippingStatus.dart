import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String showStatus = '';
  var db = FirebaseFirestore.instance;
  late BitmapDescriptor customIcon;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();

    // Listen to real-time updates from Firestore
    FirebaseFirestore.instance
        .collection('riderGetOrder')
        .doc('order${context.read<Appdata>().didFileShippingStatus.itemname}')
        .snapshots()
        .listen((snapshot) async {
      var data = snapshot.data();
      if (data != null) {
        List<String> latLngSender = data['gpsRider'].split(',');
        showStatus = data['status'];
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
        listResultsResponeDeliveryByDid.receiverGps.split(',');
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
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Google Map เต็มจอ
                Positioned.fill(
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _addMarkerAndDrawRoute();
                    },
                    initialCameraPosition: CameraPosition(
                      target: itemlocation!,
                      zoom: 16.0,
                    ),
                    markers: _markers,
                    polylines: {_polyline},
                  ),
                ),
                // รายละเอียดการจัดส่งที่สามารถเลื่อนดูได้
                DraggableScrollableSheet(
                  initialChildSize: 0.3, // ขนาดเริ่มต้นที่แสดง
                  minChildSize: 0.3, // ขนาดต่ำสุด
                  maxChildSize: 1.0, // ขนาดสูงสุด
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                      child: Container(
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.01,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'สถานะการจัดส่ง',
                                            style: TextStyle(
                                              fontSize: Get.textTheme
                                                  .headlineSmall!.fontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                      'ไรเดอร์กำลังนำส่งสินค้า' ||
                                                                  showStatus ==
                                                                      'ส่งสินค้าสำเร็จ' ||
                                                                  showStatus ==
                                                                      'ไรเดอร์เข้ารับสินค้าแล้ว'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.28,
                                                    height: height * 0.002,
                                                    color: Colors.black,
                                                  ),
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                      'ไรเดอร์กำลังนำส่งสินค้า' ||
                                                                  showStatus ==
                                                                      'ส่งสินค้าสำเร็จ' ||
                                                                  showStatus ==
                                                                      'ไรเดอร์เข้ารับสินค้าแล้ว'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.28,
                                                    height: height * 0.002,
                                                    color: Colors.black,
                                                  ),
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                  'ส่งสินค้าสำเร็จ'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                'ไรเดอร์รับออเดอร์แล้ว',
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .labelMedium!.fontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                'อยู่ระหว่างการจัดส่ง',
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .labelMedium!.fontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                'ไรเดอร์นำส่งสินค้าแล้ว',
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .labelMedium!.fontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.01),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.01,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'รายละเอียดการจัดส่ง',
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .headlineSmall!.fontSize,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                  'ส่งสินค้าสำเร็จ'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.002,
                                                    height: height * 0.05,
                                                    color: Colors.black,
                                                  ),
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                      'ไรเดอร์กำลังนำส่งสินค้า' ||
                                                                  showStatus ==
                                                                      'ส่งสินค้าสำเร็จ'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.002,
                                                    height: height * 0.05,
                                                    color: Colors.black,
                                                  ),
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                      'ไรเดอร์เข้ารับสินค้าแล้ว' ||
                                                                  showStatus ==
                                                                      'ไรเดอร์กำลังนำส่งสินค้า' ||
                                                                  showStatus ==
                                                                      'ส่งสินค้าสำเร็จ'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: width * 0.002,
                                                    height: height * 0.05,
                                                    color: Colors.black,
                                                  ),
                                                  Column(
                                                    children: [
                                                      showStatus == 'ดูสินค้า'
                                                          ? SvgPicture.string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                              width:
                                                                  width * 0.03,
                                                              height:
                                                                  height * 0.03,
                                                            )
                                                          : showStatus ==
                                                                      'รอไรเดอร์เข้ารับสินค้า' ||
                                                                  showStatus ==
                                                                      'ไรเดอร์เข้ารับสินค้าแล้ว' ||
                                                                  showStatus ==
                                                                      'ไรเดอร์กำลังนำส่งสินค้า' ||
                                                                  showStatus ==
                                                                      'ส่งสินค้าสำเร็จ'
                                                              ? SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 5c-3.859 0-7 3.141-7 7s3.141 7 7 7 7-3.141 7-7-3.141-7-7-7zm0 12c-2.757 0-5-2.243-5-5s2.243-5 5-5 5 2.243 5 5-2.243 5-5 5z"></path><path d="M12 9c-1.627 0-3 1.373-3 3s1.373 3 3 3 3-1.373 3-3-1.373-3-3-3z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                              : SvgPicture
                                                                  .string(
                                                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M5 12c0 3.859 3.14 7 7 7 3.859 0 7-3.141 7-7s-3.141-7-7-7c-3.86 0-7 3.141-7 7zm12 0c0 2.757-2.243 5-5 5s-5-2.243-5-5 2.243-5 5-5 5 2.243 5 5z"></path></svg>',
                                                                  width: width *
                                                                      0.03,
                                                                  height:
                                                                      height *
                                                                          0.03,
                                                                )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'ไรเดอร์ส่งสินค้าแล้ว',
                                                        style: TextStyle(
                                                          fontSize: Get
                                                              .textTheme
                                                              .titleMedium!
                                                              .fontSize,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.06),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'ไรเดอร์กำลังนำส่งสินค้า',
                                                        style: TextStyle(
                                                          fontSize: Get
                                                              .textTheme
                                                              .titleMedium!
                                                              .fontSize,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.06),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'ไรเดอร์เข้ารับสินค้าแล้ว',
                                                        style: TextStyle(
                                                          fontSize: Get
                                                              .textTheme
                                                              .titleMedium!
                                                              .fontSize,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.06),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'รอไรเดอร์เข้ารับสินค้า',
                                                        style: TextStyle(
                                                          fontSize: Get
                                                              .textTheme
                                                              .titleMedium!
                                                              .fontSize,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
  void _setCustomMarkerIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)), // กำหนดขนาดของภาพ
      'assets/images/motorcycle.png', // path ของภาพใน assets
    );
  }

  void _addMarkerAndDrawRoute() {
    _markers.clear();
    // Add Marker for start location
    _markers.add(
      Marker(
        markerId: const MarkerId('ไรเดอร์'),
        position: senderlocation!,
        infoWindow: const InfoWindow(
          title: 'ไรเดอร์',
        ),
            icon: customIcon,
      ),
    );

    // Add Marker for end location
    _markers.add(
      Marker(
        markerId: const MarkerId('คุณ'),
        position: itemlocation!,
        infoWindow: const InfoWindow(
          title: 'คุณ',
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
