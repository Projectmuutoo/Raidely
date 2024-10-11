import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/pagesMember/detailsShippingList.dart';
import 'package:raidely/pages/pagesMember/profileUser.dart';
import 'package:raidely/shared/appData.dart';

class HomeMemberPage extends StatefulWidget {
  const HomeMemberPage({super.key});

  @override
  State<HomeMemberPage> createState() => _HomeMemberPageState();
}

class _HomeMemberPageState extends State<HomeMemberPage> {
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
    setState(() {});
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
                              child: ClipOval(
                                child:
                                    resultsResponseMemberBody[0].imageMember ==
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
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // จัดตัวอักษรแนวตั้ง
                          children: [
                            Text(
                              resultsResponseMemberBody[0].name,
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
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
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  RefreshIndicator(
                    onRefresh: loadDataAsync,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: searchCth.text.isEmpty
                          ? SizedBox(
                              height: height * 0.7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ไม่มีรายการค้นหา',
                                    style: TextStyle(
                                      fontSize: Get
                                          .textTheme.headlineMedium!.fontSize,
                                      color: const Color(0xff856158),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                              ),
                              child: Column(
                                children:
                                    listResultsResponeMember.map((member) {
                                  return Column(
                                    children: [
                                      Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFEF7E7),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: height * 0.005,
                                            horizontal: width * 0.01,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            height:
                                                                height * 0.05,
                                                            width:
                                                                height * 0.05,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffE8DDC4),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: ClipOval(
                                                              child: member
                                                                          .imageMember ==
                                                                      '-'
                                                                  ? SvgPicture
                                                                      .string(
                                                                      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                                                      height:
                                                                          height *
                                                                              0.04,
                                                                      color: Colors
                                                                          .grey,
                                                                    )
                                                                  : Image
                                                                      .network(
                                                                      member
                                                                          .imageMember,
                                                                      width: height *
                                                                          0.04,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: width * 0.02,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          member.phone,
                                                          style: TextStyle(
                                                            fontSize: Get
                                                                .textTheme
                                                                .titleLarge!
                                                                .fontSize,
                                                            color: const Color(
                                                                0xff51281D),
                                                          ),
                                                        ),
                                                        Text(
                                                          member.name,
                                                          style: TextStyle(
                                                            fontSize: Get
                                                                .textTheme
                                                                .titleMedium!
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
                                              ElevatedButton(
                                                onPressed: () {
                                                  selectMember(member.phone);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  fixedSize: Size(
                                                    width * 0.2,
                                                    height * 0.06,
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xffAF4C31),
                                                  elevation: 1,
                                                  shadowColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text(
                                                  "เลือก",
                                                  style: TextStyle(
                                                    fontSize: Get.textTheme
                                                        .labelLarge!.fontSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> searchMember(String value) async {
    if (double.tryParse(value) == null) {
      // log('Value is NaN or not a number, skipping search.');
      return; // หากค่าเป็น NaN หรือไม่ใช่หมายเลข ให้หยุดทำงานของฟังก์ชัน
    }
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var response = await http.get(Uri.parse('$url/member/search/$value'));
    listResultsResponeMember = byPhoneMemberGetResponseFromJson(response.body);
    // กรองข้อมูลที่มีเบอร์โทรศัพท์ตรงกับผู้ใช้ที่ทำการค้นหา
    listResultsResponeMember = listResultsResponeMember.where((member) {
      return member.phone != context.read<Appdata>().loginKeepUsers.phone;
    }).toList();
    setState(() {});
  }

  selectMember(String phone) {
    KeepPhoneFileDetailsShippingList keeps = KeepPhoneFileDetailsShippingList();
    keeps.phone = phone;
    context.read<Appdata>().phoneFileDetailsShippingList = keeps;
    Get.to(() => const DetailsShippingList());
  }
}
