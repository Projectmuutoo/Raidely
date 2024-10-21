import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/request/insertDeliveryPostRequest.dart';
import 'package:raidely/models/request/updateMemberPutRequest.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/pagesMember/homeMember.dart';
import 'package:raidely/pages/pagesMember/navbottompages.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailsShippingList extends StatefulWidget {
  const DetailsShippingList({super.key});

  @override
  State<DetailsShippingList> createState() => _DetailsShippingListState();
}

class _DetailsShippingListState extends State<DetailsShippingList> {
  late Future<void> loadData;
  List<ByPhoneMemberGetResponse> combinedMembers = [];
  ImagePicker picker = ImagePicker();
  File? savedFile;
  XFile? image;
  String textNameProductCthWarningIsEmpty = '898989';
  String textNameShippingCthWarningIsEmpty = '898989';
  String textSavedFileWarningIsEmpty = '898989';
  TextEditingController nameProductCth = TextEditingController();
  TextEditingController nameShippingCth = TextEditingController();
  TextEditingController addressCth = TextEditingController();
  TextEditingController latlngCth = TextEditingController();
  LatLng? currentPosition;
  LatLng? markerPosition;
  GoogleMapController? mapController;
  bool isTyping = false;
  bool isCheck = false;

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var phone = context.read<Appdata>().loginKeepUsers.phone;
    var phoneFileDetailsShippingList =
        context.read<Appdata>().phoneFileDetailsShippingList.phone;

    var responseCourierMember = await http.get(Uri.parse('$url/member/$phone'));
    var courierMember =
        byPhoneMemberGetResponseFromJson(responseCourierMember.body);
    var responseReceiveMember =
        await http.get(Uri.parse('$url/member/$phoneFileDetailsShippingList'));
    var receiveMember =
        byPhoneMemberGetResponseFromJson(responseReceiveMember.body);

    combinedMembers = [...courierMember, ...receiveMember].toSet().toList();

    nameShippingCth.text = combinedMembers[0].name;
    addressCth.text = combinedMembers[0].address;

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
              'รายละเอียดสินค้าที่ส่ง',
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
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    RefreshIndicator(
                      onRefresh: loadDataAsync,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffFEF7E7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(width: 1),
                              ),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  TextField(
                                    controller: nameProductCth,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText:
                                          isTyping ? '' : 'ป้อนชื่อสินค้า',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleLarge!.fontSize,
                                        color: Color(
                                          int.parse(
                                              '0xff$textNameProductCthWarningIsEmpty'),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(
                                        left: width * 0.22,
                                        right: width * 0.04,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: width * 0.02,
                                    child: Text(
                                      'ชื่อสินค้า:',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleLarge!.fontSize,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffFEF7E7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.02),
                                        child: Text(
                                          'ชื่อผู้ส่ง:',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            if (snapshot.connectionState !=
                                                ConnectionState.done)
                                              Positioned(
                                                top: height * 0.03,
                                                left: width * 0.03,
                                                child: ImageFiltered(
                                                  imageFilter: ImageFilter.blur(
                                                    sigmaX: 3,
                                                    sigmaY: 3,
                                                  ),
                                                  child: Container(
                                                    color:
                                                        const Color(0x4D9E9E9E),
                                                    width: width * 0.2,
                                                    height: height * 0.002,
                                                  ),
                                                ),
                                              ),
                                            TextField(
                                              controller: nameShippingCth,
                                              keyboardType: TextInputType.text,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                hintText:
                                                    snapshot.connectionState ==
                                                            ConnectionState.done
                                                        ? 'ป้อนชื่อผู้ส่ง'
                                                        : '',
                                                hintStyle: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .titleLarge!.fontSize,
                                                  color: Color(
                                                    int.parse(
                                                        '0xff$textNameShippingCthWarningIsEmpty'),
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  left: width * 0.02,
                                                  right: width * 0.04,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.02,
                                          right: width * 0.02,
                                        ),
                                        child: Text(
                                          'เบอร์โทรผู้ส่ง:',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      snapshot.connectionState !=
                                              ConnectionState.done
                                          ? ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 3,
                                                sigmaY: 3,
                                              ),
                                              child: Container(
                                                color: const Color.fromARGB(
                                                    77, 158, 158, 158),
                                                width: width * 0.3,
                                                height: height * 0.002,
                                              ),
                                            )
                                          : Text(
                                              combinedMembers[0].phone,
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleLarge!.fontSize,
                                                color: const Color(0xFF6D6D6D),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: width * 0.02,
                                            ),
                                            child: Text(
                                              'ที่อยู่ผู้ส่ง:',
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleLarge!.fontSize,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: height * 0.01,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: height * 0.15,
                                              width: width * 0.65,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.02,
                                                vertical: height * 0.005,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(),
                                              ),
                                              constraints: BoxConstraints(
                                                maxWidth: width * 0.65,
                                              ),
                                              child: Stack(
                                                children: [
                                                  snapshot.connectionState !=
                                                          ConnectionState.done
                                                      ? Positioned(
                                                          top: height * 0.012,
                                                          left: width * 0.02,
                                                          child: ImageFiltered(
                                                            imageFilter:
                                                                ImageFilter
                                                                    .blur(
                                                              sigmaX: 3,
                                                              sigmaY: 3,
                                                            ),
                                                            child: Container(
                                                              color: const Color(
                                                                  0x4D9E9E9E),
                                                              width:
                                                                  width * 0.2,
                                                              height: height *
                                                                  0.002,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          addressCth.text,
                                                          style: TextStyle(
                                                            fontSize: Get
                                                                .textTheme
                                                                .titleMedium
                                                                ?.fontSize,
                                                            color: const Color(
                                                                0xFF000000),
                                                          ),
                                                          overflow: TextOverflow
                                                              .visible,
                                                        ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () => showMap(),
                                                      child: Text(
                                                        'เลือกตำแหน่งที่อยู่ใหม่',
                                                        style: TextStyle(
                                                          fontSize: Get
                                                              .textTheme
                                                              .titleMedium
                                                              ?.fontSize,
                                                          color: const Color(
                                                              0xFFFF0000),
                                                        ),
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.005),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: width * 0.02),
                                        child: Text(
                                          'ภาพสินค้า:',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.01),
                                  InkWell(
                                    onTap: () {
                                      final RenderBox renderBox = context
                                          .findRenderObject() as RenderBox;
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
                                        color: const Color.fromARGB(
                                            255, 203, 203, 203),
                                        items: [
                                          PopupMenuItem(
                                            value: 'แกลลอรี่',
                                            child: Text(
                                              'เลือกจากแกลลอรี่',
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium!.fontSize,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'เลือกไฟล์',
                                            child: Text(
                                              'เลือกไฟล์',
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium!.fontSize,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'ถ่ายรูป',
                                            child: Text(
                                              'ถ่ายรูป',
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium!.fontSize,
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
                                                await FilePicker.platform
                                                    .pickFiles();
                                            if (result != null) {
                                              setState(() {
                                                savedFile = File(
                                                    result.files.first.path!);
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
                                      width: width * 0.7,
                                      height: height * 0.2,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        children: [
                                                          // Container for the outer circle
                                                          Container(
                                                            height:
                                                                height * 0.08,
                                                            width: width * 0.08,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffd9d9d9),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  // White inner circle
                                                                  Container(
                                                                    height:
                                                                        height *
                                                                            0.08,
                                                                    width:
                                                                        width *
                                                                            0.08,
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
                                                                        height *
                                                                            0.06,
                                                                    width:
                                                                        width *
                                                                            0.06,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color(
                                                                          0xffd9d9d9),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                  // SVG Icon
                                                                  SvgPicture
                                                                      .string(
                                                                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                                                    height:
                                                                        height *
                                                                            0.02,
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
                                                                      '0xff$textSavedFileWarningIsEmpty'),
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
                                                        MainAxisAlignment
                                                            .center,
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
                                                            BorderRadius
                                                                .circular(12),
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: Center(
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  height * 0.08,
                                                              width:
                                                                  width * 0.08,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffd9d9d9),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Center(
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    // White inner circle
                                                                    Container(
                                                                      height:
                                                                          height *
                                                                              0.08,
                                                                      width: width *
                                                                          0.08,
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
                                                                          height *
                                                                              0.06,
                                                                      width: width *
                                                                          0.06,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Color(
                                                                            0xffd9d9d9),
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                    ),
                                                                    // SVG Icon
                                                                    SvgPicture
                                                                        .string(
                                                                      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                                                      height:
                                                                          height *
                                                                              0.02,
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
                                  SizedBox(height: height * 0.02),
                                ],
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffFEF7E7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(width: 1),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.02,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ชื่อผู้รับ: ',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                        snapshot.connectionState !=
                                                ConnectionState.done
                                            ? ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 3,
                                                  sigmaY: 3,
                                                ),
                                                child: Container(
                                                  color: const Color.fromARGB(
                                                      77, 158, 158, 158),
                                                  width: width * 0.2,
                                                  height: height * 0.002,
                                                ),
                                              )
                                            : Text(
                                                combinedMembers[1].name,
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .titleLarge!.fontSize,
                                                  color:
                                                      const Color(0xFF6D6D6D),
                                                ),
                                              ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ที่อยู่ผู้รับ: ',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: width * 0.65,
                                          ),
                                          child: snapshot.connectionState !=
                                                  ConnectionState.done
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                    top: height * 0.012,
                                                    left: width * 0.02,
                                                  ),
                                                  child: ImageFiltered(
                                                    imageFilter:
                                                        ImageFilter.blur(
                                                      sigmaX: 3,
                                                      sigmaY: 3,
                                                    ),
                                                    child: Container(
                                                      color:
                                                          const Color.fromARGB(
                                                              77,
                                                              158,
                                                              158,
                                                              158),
                                                      width: width * 0.2,
                                                      height: height * 0.002,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  combinedMembers[1].address,
                                                  style: TextStyle(
                                                    fontSize: Get.textTheme
                                                        .titleLarge!.fontSize,
                                                    color:
                                                        const Color(0xFF6D6D6D),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'เบอร์โทรผู้รับ: ',
                                          style: TextStyle(
                                            fontSize: Get
                                                .textTheme.titleLarge!.fontSize,
                                            color: Colors.black,
                                          ),
                                        ),
                                        snapshot.connectionState !=
                                                ConnectionState.done
                                            ? ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 3,
                                                  sigmaY: 3,
                                                ),
                                                child: Container(
                                                  color: const Color.fromARGB(
                                                      77, 158, 158, 158),
                                                  width: width * 0.3,
                                                  height: height * 0.002,
                                                ),
                                              )
                                            : Text(
                                                combinedMembers[1].phone,
                                                style: TextStyle(
                                                  fontSize: Get.textTheme
                                                      .titleLarge!.fontSize,
                                                  color:
                                                      const Color(0xFF6D6D6D),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: createShippingList,
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(width * 0.4, height * 0.06),
                                    backgroundColor: const Color(0xFFFEF7E7),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Color(0xff51281D),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'ยืนยัน',
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleLarge!.fontSize,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            )
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
    );
  }

  void createShippingList() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    if (nameProductCth.text.isNotEmpty &&
        nameShippingCth.text.isNotEmpty &&
        addressCth.text.isNotEmpty &&
        savedFile != null) {
      setState(() {
        textNameProductCthWarningIsEmpty = '000000';
        textNameShippingCthWarningIsEmpty = '000000';
        textSavedFileWarningIsEmpty = '000000';
      });

      // แสดง Loading Indicator
      Get.defaultDialog(
        title: "",
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        content: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: MediaQuery.of(context).size.width * 0.03),
            Text(
              'กำลังบันทึกข้อมูล..',
              style: TextStyle(
                fontSize: Get.textTheme.titleLarge!.fontSize,
                color: const Color(0xffaf4c31),
              ),
            ),
            Text(
              'เรากำลังบันทึกข้อมูล กรุณารอสักครู่...',
              style: TextStyle(
                fontSize: Get.textTheme.titleSmall!.fontSize,
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      //อัพ image ลง firebase
      // สร้างอ้างอิงไปยัง Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'shippingListUploadImage/${DateTime.now().millisecondsSinceEpoch}_${savedFile!.path.split('/').last}');
      // อัพโหลดไฟล์และรอจนกว่าจะเสร็จสิ้น
      UploadTask uploadTask = storageReference.putFile(savedFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      // รับ URL ของรูปที่อัพโหลดสำเร็จ
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      InsertDeliveryPostRequest jsonInsertDelivery = InsertDeliveryPostRequest(
        senderId: combinedMembers[0].mid,
        receiverId: combinedMembers[1].mid,
        itemName: nameProductCth.text,
        image: downloadUrl,
        status: 'รอไรเดอร์เข้ารับสินค้า',
      );

      UpdateMemberPutRequest jsonUpdateMember = UpdateMemberPutRequest(
        name: nameShippingCth.text, //ชื่อคนส่ง
        password: combinedMembers[0].password, //password เดิม
        address: combinedMembers[0].address, //ที่อยู่เดิม
        //ถ้าหากมีการเปลี่ยนที่อยู่ใหม่ให้บันทึก gps ใหม่ลง
        gps:
            latlngCth.text.isNotEmpty ? latlngCth.text : combinedMembers[0].gps,
        imageMember: combinedMembers[0].imageMember, //รูปเดิม
      );

      var responsePostJsonDelivery = await http.post(
        Uri.parse("$url/delivery/insert"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: insertDeliveryPostRequestToJson(jsonInsertDelivery),
      );
      var responsePutJsonUpdateMember = await http.put(
        Uri.parse("$url/member/updatemember/${combinedMembers[0].phone}"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: updateMemberPutRequestToJson(jsonUpdateMember),
      );

      if (responsePostJsonDelivery.statusCode == 200) {
        if (responsePutJsonUpdateMember.statusCode == 200) {
          var db = FirebaseFirestore.instance;
          var data = {
            'status': 'รอไรเดอร์รับของ',
          };
          db
              .collection('detailsShippingList')
              .doc('order${nameProductCth.text}')
              .set(data);
          // back Loading Indicator
          Get.back();
          Get.defaultDialog(
            title: "",
            titlePadding: EdgeInsets.zero,
            content: Column(
              children: [
                Image.asset(
                  'assets/images/success.png',
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                Text(
                  'บันทึกข้อมูลสำเร็จ!',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // setState(() {
                  //   savedFile = null;
                  //   loadDataAsync();
                  // });
                  Get.to(() => NavbottompagesPage(selectedPage: 1));
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
            ],
          );
        }
      }
    } else {
      if (nameProductCth.text.isEmpty) {
        setState(() {
          textNameProductCthWarningIsEmpty = 'ff0000';
        });
      }
      if (nameShippingCth.text.isEmpty) {
        setState(() {
          textNameShippingCthWarningIsEmpty = 'ff0000';
        });
      }
      if (savedFile == null) {
        setState(() {
          textSavedFileWarningIsEmpty = 'ff0000';
        });
      }
    }
  }

  Future<void> getGPS() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // print('Location permissions are denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void showMap() {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext bc) {
        return SizedBox(
          height: height * 0.9,
          child: FutureBuilder(
            future: getGPS(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              markerPosition = currentPosition;

              return StatefulBuilder(
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.01,
                                  vertical: height * 0.005,
                                ),
                                child: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12.707 17.293 8.414 13H18v-2H8.414l4.293-4.293-1.414-1.414L4.586 12l6.707 6.707z"></path></svg>',
                                  height: height * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: height * 0.85,
                                child: GoogleMap(
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    mapController = controller;
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: currentPosition!,
                                    zoom: 15,
                                  ),
                                  markers: {
                                    if (markerPosition != null)
                                      Marker(
                                        markerId:
                                            const MarkerId('currentLocation'),
                                        position: markerPosition!,
                                        infoWindow: const InfoWindow(
                                            title: 'Your Location'),
                                      ),
                                  },
                                  onTap: (LatLng latLng) {
                                    snapshot(() {
                                      markerPosition = latLng;
                                    });
                                    mapController?.animateCamera(
                                        CameraUpdate.newLatLng(
                                            markerPosition!));
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: height * 0.02,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (currentPosition != null) {
                                          snapshot(() {
                                            markerPosition = currentPosition;
                                          });
                                          mapController?.animateCamera(
                                              CameraUpdate.newLatLng(
                                                  currentPosition!));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize:
                                            Size(width * 0.4, height * 0.04),
                                        backgroundColor:
                                            const Color(0xFFFEF7E7),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        'ตำแหน่งปัจจุบัน',
                                        style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: Colors.black),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (markerPosition != null) {
                                          List<Placemark> placemarks =
                                              await placemarkFromCoordinates(
                                            markerPosition!.latitude,
                                            markerPosition!.longitude,
                                          );

                                          if (placemarks.isNotEmpty) {
                                            Placemark place = placemarks[0];

                                            setState(() {
                                              addressCth.text =
                                                  '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

                                              latlngCth.text =
                                                  '${markerPosition?.latitude},${markerPosition?.longitude}';
                                            });

                                            Get.back();
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize:
                                            Size(width * 0.4, height * 0.04),
                                        backgroundColor:
                                            const Color(0xFFAF4C31),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        'ยืนยันตำแหน่ง',
                                        style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
