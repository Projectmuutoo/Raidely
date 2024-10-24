import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
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

  @override
  void initState() {
    super.initState();
    loadDataAsync(); // Load data when the widget initializes
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

      // var did = responseReceiver[0]

      log(responseReceiver.body.toString());
      log(mid); // Log the mid after conversion to String
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
      body: FutureBuilder(
        future: loadDataAsync(), // Call loadData once
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error state
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Data is loaded
            if (errorMessage != null) {
              return Center(child: Text('Error: $errorMessage'));
            }

            return Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ElevatedButton(
                    onPressed: showMap,
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
                      "ดูสินค้าทั้งหมด", // เปลี่ยนข้อความตามสถานะ
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void showMap() {
    // Get.to(() => ReceiverMapPage(did)); // Pass 'did' as an int
  }
}
