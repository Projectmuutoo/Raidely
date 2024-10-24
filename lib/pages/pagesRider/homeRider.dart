import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
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
              color: Colors.white,
              height: height,
              child: RefreshIndicator(
                onRefresh: loadDataAsync,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: listResultsResponeDeliveryAll.isEmpty
                      ? Container(
                          color: Colors.white,
                          height: height,
                          width: width,
                        )
                      : Column(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                        fontSize: Get
                                                            .textTheme
                                                            .titleLarge!
                                                            .fontSize,
                                                        color: const Color(
                                                            0xff51281D),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      value.senderName,
                                                      style: TextStyle(
                                                        fontSize: Get
                                                            .textTheme
                                                            .titleLarge!
                                                            .fontSize,
                                                        color: const Color(
                                                            0xff51281D),
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
                                                  getOrder(value.did,
                                                      value.itemName);
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
                                                        BorderRadius.circular(
                                                            24),
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
                                                    getOrderDetails(value.did,
                                                        value.itemName),
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
                                                        BorderRadius.circular(
                                                            24),
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

  getOrder(int value, String itemName) async {
    var db = FirebaseFirestore.instance;
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    final permission = await Geolocator.requestPermission();
    // var did = context.read<Appdata>().didInTableDelivery.did;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // print('Location permissions are denied');
      return;
    }
    // แสดง Popup ก่อนที่จะส่งค่าไปทำงานต่อ
    bool confirm = await Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      content: Column(
        children: [
          Image.asset(
            'assets/images/question.png',
            width: MediaQuery.of(context).size.width * 0.16,
            height: MediaQuery.of(context).size.width * 0.16,
            fit: BoxFit.cover,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.03),
          Text(
            'คุณแน่ใจว่าต้องการรับสินค้านี้?',
            style: TextStyle(
              fontSize: Get.textTheme.titleLarge!.fontSize,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
      actions: [
        ElevatedButton(
          onPressed: () async {
            var result = await db
                .collection('detailsShippingList')
                .doc('order$itemName')
                .get();
            var datas = result.data();

            if (datas!['status'] == 'ไรเดอร์เข้ารับสินค้าแล้ว') {
              Get.defaultDialog(
                  title: "",
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  content: Column(
                    children: [
                      Image.asset(
                        'assets/images/warning.png',
                        width: MediaQuery.of(context).size.width * 0.16,
                        height: MediaQuery.of(context).size.width * 0.16,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.03),
                      Text(
                        'มีไรเดอร์รับสินค้านี้แล้ว!',
                        style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: const Color(0xffaf4c31),
                        ),
                      ),
                    ],
                  ),
                  barrierDismissible: false,
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back(result: false);
                        Get.back(result: false);
                        loadDataAsync();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.3,
                          MediaQuery.of(context).size.height * 0.05,
                        ),
                        backgroundColor: const Color(0xffFEF7E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: Get.textTheme.titleSmall!.fontSize,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]);
              return;
            }

            var data = {
              'status': 'ไรเดอร์เข้ารับสินค้าแล้ว',
              'sender_Gps': datas['sender_Gps'],
              'receiver_Gps': datas['receiver_Gps'],
            };
            db
                .collection('detailsShippingList')
                .doc('order$itemName')
                .set(data);

            Get.back(result: true);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(
              MediaQuery.of(context).size.width * 0.3,
              MediaQuery.of(context).size.height * 0.05,
            ),
            backgroundColor: const Color(0xffD5843D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            'ยืนยัน',
            style: TextStyle(
              fontSize: Get.textTheme.titleSmall!.fontSize,
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(result: false);
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(
              MediaQuery.of(context).size.width * 0.3,
              MediaQuery.of(context).size.height * 0.05,
            ),
            backgroundColor: const Color(0xffFEF7E7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            'ยกเลิก',
            style: TextStyle(
              fontSize: Get.textTheme.titleSmall!.fontSize,
              color: Colors.black,
            ),
          ),
        ),
      ],
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
      db.collection('riderGetOrder').doc('order$itemName').set(data);

      KeepDidInTableDelivery keep = KeepDidInTableDelivery();
      keep.clickGetorder = true;
      keep.did = value.toString();
      keep.itemname = itemName;
      context.read<Appdata>().didInTableDelivery = keep;

      var jsonriderass = {
        'delivery_id': value,
        'rider_id': resultsResponseRiderBody[0].rid,
        'status': "ไรเดอร์เข้ารับสินค้าแล้ว",
        'image_receiver': '-',
        'image_success': '-'
      };
      var responsePostJsonRiderass = await http.post(
        Uri.parse("$url/rider_assigns/insert"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(jsonriderass), // Use the encoded JSON string directly
      );

      if (responsePostJsonRiderass.statusCode == 200) {
        var json = {
          "status": "ไรเดอร์เข้ารับสินค้าแล้ว",
          'image_receiver': '-',
          'image_success': '-'
        };
        var responsePutJsonUpdateMember = await http.put(
          Uri.parse("$url/delivery/update/$value"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(json),
        );

        if (responsePutJsonUpdateMember.statusCode == 200) {
          Get.to(() => const GetorderPage());
        }
      }
    }
  }

  void getOrderDetails(int value, String itemname) async {
    var db = FirebaseFirestore.instance;
    // สร้าง KeepDidInTableDelivery ใหม่

    KeepDidInTableDelivery keep = KeepDidInTableDelivery();
    keep.did = value.toString();
    keep.itemname = itemname;
    context.read<Appdata>().didInTableDelivery = keep;

    // ตรวจสอบว่าค่าปัจจุบันคือ clickGetorder เป็น true หรือไม่
    if (context.read<Appdata>().didInTableDelivery.clickGetorder) {
      // ถ้าเป็น true, ปรับค่า clickGetorder เป็น false
      keep.clickGetorder = false;
      context.read<Appdata>().didInTableDelivery = keep;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var data = {
      'gpsRider': '${position.latitude},${position.longitude}',
      'did': value,
      'status': 'ดูสินค้า',
    };
    db.collection('riderGetOrder').doc('order$itemname').update(data);

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
