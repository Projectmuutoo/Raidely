import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/DeliveryByMidGetResponse.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/pagesMember/profileUser.dart';
import 'package:raidely/pages/pagesMember/shippingStatus.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;

class CreateshippinglistPage extends StatefulWidget {
  const CreateshippinglistPage({super.key});

  @override
  State<CreateshippinglistPage> createState() => _CreateshippinglistPageState();
}

class _CreateshippinglistPageState extends State<CreateshippinglistPage> {
  late Future<void> loadData;
  late List<ByPhoneMemberGetResponse> resultsResponseMemberBody = [];
  late List<DeliveryByMidGetResponse> resultsResponseDeliveryByMid = [];
  bool isTyping = false;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var phone = context.read<Appdata>().loginKeepUsers.phone;

    var responseMember = await http.get(Uri.parse('$url/member/$phone'));
    resultsResponseMemberBody =
        byPhoneMemberGetResponseFromJson(responseMember.body);
    var responseDeliverySenderId = await http.get(
        Uri.parse('$url/delivery/sender/${resultsResponseMemberBody[0].mid}'));
    resultsResponseDeliveryByMid =
        deliveryByMidGetResponseFromJson(responseDeliverySenderId.body);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: loadData,
      builder: (context, snapshot) {
        return Scaffold(
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
                        Get.to(() => const ProfileUserPage());
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
                            child:
                                snapshot.connectionState != ConnectionState.done
                                    ? ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 3,
                                          sigmaY: 3,
                                        ),
                                        child: Container(
                                          color: const Color.fromARGB(
                                              77, 158, 158, 158),
                                        ),
                                      )
                                    : ClipOval(
                                        child: resultsResponseMemberBody[0]
                                                    .imageMember ==
                                                '-'
                                            ? SvgPicture.string(
                                                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                                height: height * 0.05,
                                                color: Colors.grey,
                                              )
                                            : Image.network(
                                                resultsResponseMemberBody[0]
                                                    .imageMember,
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
                      child: snapshot.connectionState != ConnectionState.done
                          ? ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 3,
                                sigmaY: 3,
                              ),
                              child: Container(
                                color: const Color.fromARGB(77, 158, 158, 158),
                                width: width * 0.2,
                                height: height * 0.002,
                              ),
                            )
                          : Text(
                              resultsResponseMemberBody[0].name,
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                elevation: 1,
                automaticallyImplyLeading: false,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: loadDataAsync,
            child: snapshot.connectionState != ConnectionState.done
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : resultsResponseDeliveryByMid.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่มีรายการส่งสินค้า',
                          style: TextStyle(
                            fontSize: Get.textTheme.headlineMedium!.fontSize,
                            color: const Color(0xff856158),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: resultsResponseDeliveryByMid.length,
                        itemBuilder: (context, index) {
                          var value = resultsResponseDeliveryByMid[index];
                          return Container(
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
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
                                                    fontSize: Get.textTheme
                                                        .titleLarge!.fontSize,
                                                    color:
                                                        const Color(0xff51281D),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: height * 0.005),
                                                Text(
                                                  'ถึง: ${value.receiverName}',
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
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        value.status,
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.labelLarge!.fontSize,
                                          color: const Color(0xff51281D),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      ElevatedButton(
                                        onPressed: () {
                                          getStatusShipping(
                                              value.did, value.itemName);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: Size(
                                            width * 0.28,
                                            height * 0.04,
                                          ),
                                          backgroundColor:
                                              const Color(0xff7C7C7C),
                                          elevation: 2,
                                          shadowColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "รายละเอียด",
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleSmall!.fontSize,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }

  getStatusShipping(int value, String itemname) {
    KeepDidFileShippingStatus keeps = KeepDidFileShippingStatus();
    keeps.did = value.toString();
    keeps.itemname = itemname;
    context.read<Appdata>().didFileShippingStatus = keeps;
    Get.to(() => const ShippingstatusPage());
  }
}
