import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/DeliveryByMidGetResponse.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/pagesMember/details.dart';
import 'package:raidely/pages/pagesMember/receiverMap.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;

class ListproductsreceivedPage extends StatefulWidget {
  const ListproductsreceivedPage({super.key});

  @override
  State<ListproductsreceivedPage> createState() =>
      _ListproductsreceivedPageState();
}

class _ListproductsreceivedPageState extends State<ListproductsreceivedPage> {
  String? errorMessage;
  var db = FirebaseFirestore.instance;
  late List<ByPhoneMemberGetResponse> resultsResponseMemberBody = [];
  late List<DeliveryByMidGetResponse> resultsResponseDeliveryBody = [];
  late StreamSubscription statusShipping;
  StreamSubscription? statusSubscription;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    loadDataAsync(); // Load data when the widget initializes
    startRealtimeStatusListener();
    // Log the markers set to confirm marker addition
  }

  Future<void> loadDataAsync() async {
    try {
      var config = await Configuration.getConfig();
      var url = config['apiEndpoint'].toString();
      var apiKey = config['apiKey'];

      var phone = context.read<Appdata>().loginKeepUsers.phone;
      var responseMember = await http.get(Uri.parse('$url/member/$phone'));
      resultsResponseMemberBody =
          byPhoneMemberGetResponseFromJson(responseMember.body);

      // Convert mid to String using toString()
      var mid = resultsResponseMemberBody[0].mid.toString();

      var responseReceiver =
          await http.get(Uri.parse('$url/delivery/receiver/$mid'));
      resultsResponseDeliveryBody =
          deliveryByMidGetResponseFromJson(responseReceiver.body);
    } catch (e) {
      errorMessage = e.toString(); // Capture error message
      log('Error fetching products: $errorMessage'); // Log error
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            FutureBuilder(
              future: loadDataAsync(), // Call loadData once
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return resultsResponseDeliveryBody.isEmpty
                    ? SizedBox(
                        height: height * 0.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ไม่มีรายการที่ได้รับสินค้า',
                              style: TextStyle(
                                fontSize:
                                    Get.textTheme.headlineMedium!.fontSize,
                                color: const Color(0xff856158),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: resultsResponseDeliveryBody.map((data) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'ชื่อสินค้า: ${data.itemName}',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleLarge!.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('ผู้ส่ง: ${data.senderName}'),
                                    Text('สถานะ: ${data.status}'),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => details(data.did),
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(
                                          width * 0.4,
                                          height * 0.05,
                                        ),
                                        backgroundColor:
                                            const Color(0xffD5843D),
                                        elevation: 3, // Button shadow
                                        shadowColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              24), // Rounded corners
                                        ),
                                      ),
                                      child: Text(
                                        "รายละเอียด", // View all products
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.network(
                                      data.image,
                                      width: width * 0.2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  void details(int did) {
    // Pass 'did' to the map page
    Get.to(() => DetailsPage(
        did: did)); // Assuming ReceiverMapPage takes a 'did' as parameter
  }

  void startRealtimeStatusListener() {
    statusSubscription = FirebaseFirestore.instance
        .collection('detailsShippingList')
        .doc('orderabc')
        .snapshots()
        .listen((result) {
      var data = result.data();
      if (data != null) {
        log(data['status']);
      }
    });
    setState(() {
      isListening = true; // Set listening to true
    });
  }

  void stopRealtimeStatusListener() {
    if (statusSubscription != null) {
      statusSubscription!.cancel();
      statusSubscription = null; // Set to null to indicate it's stopped
      setState(() {
        isListening = false; // Set listening to false
      });
      log("Listener stopped");
    }
  }

  @override
  void dispose() {
    if (isListening && statusSubscription != null) {
      statusSubscription!.cancel(); // Cancel subscription on dispose
    }
    super.dispose();
  }
}
