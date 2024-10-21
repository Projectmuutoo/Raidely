import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/request/insertRiderassignmentPost.dart';
import 'package:raidely/models/response/byPhoneRiderGetResponse.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/models/response/deliveryAllGetResponse.dart';
import 'package:raidely/pages/pagesRider/getOrder.dart';
import 'package:raidely/pages/pagesRider/profileRider.dart';
import 'package:raidely/shared/appData.dart';

class HomeriderPage extends StatefulWidget {
  const HomeriderPage({super.key});

  @override
  State<HomeriderPage> createState() => _HomeriderPageState();
}

class _HomeriderPageState extends State<HomeriderPage> {
  late Future<void> loadData;
  late List<ByPhoneRiderGetResponse> resultsResponseRiderBody = [];
  late List<DeliveryAllGetResponse> listResultsResponeDeliveryAll = [];

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var phone = context.read<Appdata>().loginKeepUsers.phone;
    var responseRider = await http.get(Uri.parse('$url/rider/$phone'));
    resultsResponseRiderBody =
        byPhoneRiderGetResponseFromJson(responseRider.body);

    listOrderRiderShow();
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder(
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
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(
                width,
                width * 0.2,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: height * 0.008,
                ),
                child: AppBar(
                  title: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() => const ProfileRiderPage());
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: height * 0.06,
                              width: height * 0.06,
                              decoration: const BoxDecoration(
                                color: Color(0xffd9d9d9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: ClipOval(
                                child: resultsResponseRiderBody[0].imageRider ==
                                        '-'
                                    ? SvgPicture.string(
                                        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                        height: height * 0.05,
                                        color: Colors.grey,
                                      )
                                    : Image.network(
                                        resultsResponseRiderBody[0].imageRider,
                                        height: height * 0.06,
                                        width: height * 0.06,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resultsResponseRiderBody[0].name,
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
              ),
            ),
            body: Container(
              color: const Color(0xffD9D9D9),
              height: height,
              child: RefreshIndicator(
                onRefresh: loadDataAsync,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: listResultsResponeDeliveryAll.map(
                      (value) {
                        return Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xffFEF7E7),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.03,
                                  vertical: height * 0.01,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          value.image,
                                          width: width * 0.15,
                                          fit: BoxFit.contain,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: width * 0.03,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                value.itemName,
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .titleLarge!.fontSize,
                                                  color:
                                                      const Color(0xff51281D),
                                                ),
                                              ),
                                              SizedBox(height: height * 0.005),
                                              Text(
                                                value.senderName,
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .titleLarge!.fontSize,
                                                  color:
                                                      const Color(0xff51281D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.02),
                                    Container(
                                      width: width,
                                      height: 1,
                                      color: const Color(0xffBFBFBF),
                                    ),
                                    SizedBox(height: height * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            getOrder(value.did);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(
                                              width * 0.32,
                                              height * 0.05,
                                            ),
                                            backgroundColor:
                                                const Color(0xff1EAC81),
                                            elevation: 2,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: Text(
                                            "รับออเดอร์นี้",
                                            style: TextStyle(
                                              fontSize: Get.textTheme
                                                  .titleLarge!.fontSize,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              getOrderDetails(value.did),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(
                                              width * 0.32,
                                              height * 0.05,
                                            ),
                                            backgroundColor:
                                                const Color(0xff7C7C7C),
                                            elevation: 2,
                                            shadowColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: Text(
                                            "รายละเอียด",
                                            style: TextStyle(
                                              fontSize: Get.textTheme
                                                  .titleLarge!.fontSize,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                          ],
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  getOrder(int value) async {
    var db = FirebaseFirestore.instance;
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    final permission = await Geolocator.requestPermission();
    var riderId = resultsResponseRiderBody[0].rid;
    // var did = context.read<Appdata>().didInTableDelivery.did;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // print('Location permissions are denied');
      return;
    }

    var responseCheckorders = await http.get(
      Uri.parse("$url/delivery/check-order/$value"),
      headers: {"Content-Type": "application/json"},
    );

    if (responseCheckorders.statusCode == 404) {
      // No pending orders found
      log('No pending orders found for delivery ID: $value');
      log('Response body: ${responseCheckorders.body}'); // Log the response body
      return; // Stop execution if no orders are found
    } else {
      // แสดง Popup ก่อนที่จะส่งค่าไปทำงานต่อ
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ยืนยันคำสั่ง'),
            content:
                Text('คุณแน่ใจว่าต้องการเข้ารับสินค้าหมายเลข $value หรือไม่?'),
            actions: [
              TextButton(
                child: const Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context).pop(false); // ส่งค่ากลับว่าไม่ยืนยัน
                },
              ),
              TextButton(
                child: const Text('ยืนยัน'),
                onPressed: () async {
                  var result = await db
                      .collection('detailsShippingList')
                      .doc('order${listResultsResponeDeliveryAll[0].itemName}')
                      .get();
                  var datas = result.data();

                  if (datas!['status'] == 'ไรเดอร์รับของแล้ว') {
                    log('ไรเดอร์รับของแล้ว');
                    return;
                  }

                  var data = {
                    'status': 'ไรเดอร์รับของแล้ว',
                  };
                  db
                      .collection('detailsShippingList')
                      .doc('order${listResultsResponeDeliveryAll[0].itemName}')
                      .set(data);

                  Navigator.of(context).pop(true); // ส่งค่ากลับว่ายืนยัน
                },
              ),
            ],
          );
        },
      );

      // หากผู้ใช้ยืนยัน ก็ทำการส่งค่าต่อไป
      if (confirm) {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        var data = {
          'gpsRider': '${position.latitude},${position.longitude}',
          'did': value,
          'status': 'ไรเดอร์เข้ารับสินค้าแล้ว'
        };

        db.collection('rider').doc('order$value').set(data);

        KeepDidInTableDelivery keep = KeepDidInTableDelivery();
        keep.clickGetorder = true;
        keep.did = value.toString();
        context.read<Appdata>().didInTableDelivery = keep;

        if (resultsResponseRiderBody.isEmpty) {
          log("No rider data available");
          return;
        }

        var jsonriderass = {
          'delivery_id': value,
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
          var json = {"status": "ไรเดอร์เข้ารับสินค้าแล้ว"};
          var responsePutJsonUpdateMember = await http.put(
            Uri.parse("$url/delivery/update/$value"),
            headers: {"Content-Type": "application/json; charset=utf-8"},
            body: jsonEncode(json),
          );
          log('เข้าอันนี้ละ1');
          Get.to(() => const GetorderPage());
        } else {
          log("can't receive order");
        }
      }
    }
  }

  void getOrderDetails(int value) {
    // สร้าง KeepDidInTableDelivery ใหม่
    KeepDidInTableDelivery keep = KeepDidInTableDelivery();
    keep.did = value.toString();
    context.read<Appdata>().didInTableDelivery = keep;

    // ตรวจสอบว่าค่าปัจจุบันคือ clickGetorder เป็น true หรือไม่
    if (context.read<Appdata>().didInTableDelivery.clickGetorder) {
      // ถ้าเป็น true, ปรับค่า clickGetorder เป็น false
      keep.clickGetorder = false;
      context.read<Appdata>().didInTableDelivery = keep;
    }

    // ส่งค่าที่ต้องการไปยัง GetorderPage
    Get.to(() => const GetorderPage()); // ส่งค่า value ไปยัง GetorderPage
  }

  void listOrderRiderShow() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var response = await http.get(Uri.parse('$url/delivery/all'));
    var results = deliveryAllGetResponseFromJson(response.body);

    //หาเฉพาะ รอไรเดอร์เข้ารับสินค้า เอาออกมาแสดง
    var filteredResults = results
        .where((value) => value.status == 'รอไรเดอร์เข้ารับสินค้า')
        .toList();

    if (filteredResults.isNotEmpty) {
      listResultsResponeDeliveryAll = filteredResults;
    } else {
      listResultsResponeDeliveryAll = [];
    }

    setState(() {});
  }
}
