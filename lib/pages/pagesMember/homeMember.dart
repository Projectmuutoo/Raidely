import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/pagesMember/detailsShippingList.dart';
import 'package:raidely/pages/pagesMember/profileUser.dart';
import 'package:raidely/shared/appData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchCth = TextEditingController();
  late Future<void> loadData;
  bool isTyping = false;
  late List<ByPhoneMemberGetResponse> resultsResponseMemberBody = [];
  late List<ByPhoneMemberGetResponse> listResultsResponeMember = [];

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
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

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
                        Get.to(() => const ProfilePage());
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
                            child: SvgPicture.string(
                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                              height: height * 0.05,
                              color: Colors.grey,
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // จัดตัวอักษรแนวตั้ง
                        children: [
                          Text(
                            'ธเนดดดดดดดด',
                            style: TextStyle(
                              fontSize: Get.textTheme.titleMedium!.fontSize,
                              color: Colors.black,
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                height: height * 0.04,
                                width: width * 0.6,
                                decoration: BoxDecoration(
                                  color: const Color(0xffE0D7C3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextField(
                                  controller: searchCth,
                                  keyboardType: TextInputType.phone,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: isTyping
                                        ? ''
                                        : 'ใส่เบอร์คนที่คุณอยากส่งของ',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.labelMedium!.fontSize,
                                      color: const Color(0xff898989),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: height * 0.05,
                                    ),
                                    contentPadding: EdgeInsets.only(
                                      left: width * 0.08,
                                      right: width * 0.04,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (searchCth) {
                                    setState(() {
                                      isTyping = searchCth
                                          .isNotEmpty; // ตรวจสอบว่ามีการพิมพ์อยู่หรือไม่
                                    });
                                    searchMember(searchCth);
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: width * 0.01,
                                child: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M10 18a7.952 7.952 0 0 0 4.897-1.688l4.396 4.396 1.414-1.414-4.396-4.396A7.952 7.952 0 0 0 18 10c0-4.411-3.589-8-8-8s-8 3.589-8 8 3.589 8 8 8zm0-14c3.309 0 6 2.691 6 6s-2.691 6-6 6-6-2.691-6-6 2.691-6 6-6z"></path></svg>',
                                  height: height * 0.03,
                                  color: const Color(0xff51281D),
                                ),
                              ),
                            ],
                          ),
                        ],
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
          body: FutureBuilder(
              future: loadData,
              builder: (context, snapshot) {
                // if (snapshot.connectionState != ConnectionState.done) {
                //   return Container(
                //     color: Colors.white,
                //     child: const Center(
                //       child: CircularProgressIndicator(),
                //     ),
                //   );
                // }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RefreshIndicator(
                        onRefresh: loadDataAsync,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: listResultsResponeMember.map((member) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: ListTile(
                                  title: Text(member.name),
                                  subtitle: Text(
                                      'Phone: ${member.phone}\nAddress: ${member.address}'),
                                  isThreeLine: true,
                                  trailing: ElevatedButton(
                                    onPressed: () => selectMember(
                                        // context
                                        //     .read<Appdata>()
                                        //     .loginKeepUsers
                                        //     .phone,
                                        member
                                            .phone), // เรียกฟังก์ชันที่ส่งเบอร์โทร
                                    child: Text('เลือก'),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ));
  }

  Future<void> searchMember(String value) async {
    if (double.tryParse(value) == null) {
      log('Value is NaN or not a number, skipping search.');
      return; // หากค่าเป็น NaN หรือไม่ใช่หมายเลข ให้หยุดทำงานของฟังก์ชัน
    }
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var response = await http.get(Uri.parse('$url/member/search/$value'));
    listResultsResponeMember = byPhoneMemberGetResponseFromJson(response.body);
    // listResultsResponeMember.forEach((member) {
    //   log('Member ID: ${member.mid}, Name: ${member.name}, Phone: ${member.phone}, Address: ${member.address}, GPS: ${member.gps}');
    // });
    setState(() {});
  }

  selectMember(String recivephones) {
    Get.to(() => DetailsShippingList(recivephones));
    // log(deliveryphone + ' ' + recivephones);
  }
}
