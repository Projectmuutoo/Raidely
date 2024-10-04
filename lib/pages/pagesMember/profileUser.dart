import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/request/updateMemberPutRequest.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/pages/login.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<void> loadData;
  TextEditingController phoneCth = TextEditingController();
  TextEditingController nameCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController latlng = TextEditingController();
  TextEditingController sameLocationAaddressText = TextEditingController();
  TextEditingController sameLocationAaddresstextShow = TextEditingController();
  bool isTyping = false;
  bool sameLocationAaddress = false;
  bool editInformation = false;
  late List<ByPhoneMemberGetResponse> resultsResponseMemberBody = [];
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  @override
  void initState() {
    sameLocationAaddressText.text = 'เลือกตำแหน่ง';
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
    setState(() {
      phoneCth.text = resultsResponseMemberBody[0].phone;
      nameCth.text = resultsResponseMemberBody[0].name;
      passwordCth.text = resultsResponseMemberBody[0].password;
      addressCtl.text = resultsResponseMemberBody[0].address;
    });
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
              'ข้อมูลส่วนตัว',
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      editInformation
                          ? InkWell(
                              onTap: () {
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    1,
                                    height * 0.26,
                                    0,
                                    0,
                                  ),
                                  color:
                                      const Color.fromARGB(255, 203, 203, 203),
                                  items: [
                                    PopupMenuItem(
                                      value: 'แกลลอรี่',
                                      child: Text(
                                        'เลือกจากแกลลอรี่',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'เลือกไฟล์',
                                      child: Text(
                                        'เลือกไฟล์',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'ถ่ายรูป',
                                      child: Text(
                                        'ถ่ายรูป',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
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
                              child: Container(
                                height: height * 0.1,
                                width: width * 0.22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  children: [
                                    savedFile != null
                                        ? Positioned(
                                            right: -width * 0.005,
                                            top: -height * 0.005,
                                            child: InkWell(
                                              onTap: () {
                                                savedFile = null;
                                                setState(() {});
                                              },
                                              child: SvgPicture.string(
                                                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="m16.192 6.344-4.243 4.242-4.242-4.242-1.414 1.414L10.535 12l-4.242 4.242 1.414 1.414 4.242-4.242 4.243 4.242 1.414-1.414L13.364 12l4.242-4.242z"></path></svg>',
                                                width: width * 0.06,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    Container(
                                      height: height * 0.1,
                                      decoration: const BoxDecoration(
                                        color: Color(0xffd9d9d9),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    savedFile == null
                                        ? Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: ClipOval(
                                              child: resultsResponseMemberBody[
                                                              0]
                                                          .imageMember ==
                                                      '-'
                                                  ? Container(
                                                      height: height * 0.1,
                                                      width: width * 0.25,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            height:
                                                                height * 0.1,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffd9d9d9),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            left: 0,
                                                            right: 0,
                                                            bottom: 0,
                                                            child: SvgPicture
                                                                .string(
                                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                                              height:
                                                                  height * 0.07,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : Image.network(
                                                      resultsResponseMemberBody[
                                                              0]
                                                          .imageMember,
                                                      height: height * 0.1,
                                                      width: width * 0.2,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          )
                                        : Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: ClipOval(
                                              child: Image.file(
                                                savedFile!,
                                                height: height * 0.1,
                                                width: width * 0.2,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      width: width * 0.1,
                                      child: Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              height: height * 0.03,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Container(
                                              height: height * 0.025,
                                              decoration: const BoxDecoration(
                                                color: Color(0xffd9d9d9),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SvgPicture.string(
                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                              height: height * 0.02,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ClipOval(
                              child: resultsResponseMemberBody[0].imageMember ==
                                      '-'
                                  ? Container(
                                      height: height * 0.1,
                                      width: width * 0.25,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: height * 0.1,
                                            decoration: const BoxDecoration(
                                              color: Color(0xffd9d9d9),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: SvgPicture.string(
                                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                              height: height * 0.07,
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Image.network(
                                      resultsResponseMemberBody[0].imageMember,
                                      height: height * 0.1,
                                      width: width * 0.22,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                      SizedBox(height: height * 0.02),
                      Text(
                        resultsResponseMemberBody[0].name,
                        style: TextStyle(
                          fontSize: Get.textTheme.headlineSmall!.fontSize,
                          color: Colors.black,
                          shadows: const [
                            Shadow(
                              blurRadius: 1,
                              offset: Offset(2, 1),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.03,
                              bottom: height * 0.002,
                              top: height * 0.01,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'หมายเลขโทรศัพท์',
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffE2E2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          cursorColor: Colors.black,
                          enabled: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: resultsResponseMemberBody[0].phone,
                            hintStyle: TextStyle(
                              fontSize: Get.textTheme.titleSmall!.fontSize,
                              color: const Color(0xff898989),
                            ),
                            constraints: BoxConstraints(
                              maxHeight: height * 0.05,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.03,
                              bottom: height * 0.002,
                              top: height * 0.01,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'ชื่อ',
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!editInformation)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: nameCth,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.black,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: resultsResponseMemberBody[0].name,
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      if (editInformation)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: nameCth,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                iconSize: height * 0.03,
                                icon: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.045 7.401c.378-.378.586-.88.586-1.414s-.208-1.036-.586-1.414l-1.586-1.586c-.378-.378-.88-.586-1.414-.586s-1.036.208-1.413.585L4 13.585V18h4.413L19.045 7.401zm-3-3 1.587 1.585-1.59 1.584-1.586-1.585 1.589-1.584zM6 16v-1.585l7.04-7.018 1.586 1.586L7.587 16H6zm-2 4h16v2H4z"></path></svg>',
                                ),
                                onPressed: null,
                              ),
                              hintText: isTyping ? '' : 'ป้อนชื่อของคุณ',
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.03,
                              bottom: height * 0.002,
                              top: height * 0.01,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'รหัสผ่าน',
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!editInformation)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            obscureText: true,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: resultsResponseMemberBody[0]
                                  .password
                                  .replaceAll(RegExp('.'), '*'),
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      if (editInformation)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            obscureText: false,
                            controller: passwordCth,
                            keyboardType: TextInputType.visiblePassword,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                iconSize: height * 0.03,
                                icon: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.045 7.401c.378-.378.586-.88.586-1.414s-.208-1.036-.586-1.414l-1.586-1.586c-.378-.378-.88-.586-1.414-.586s-1.036.208-1.413.585L4 13.585V18h4.413L19.045 7.401zm-3-3 1.587 1.585-1.59 1.584-1.586-1.585 1.589-1.584zM6 16v-1.585l7.04-7.018 1.586 1.586L7.587 16H6zm-2 4h16v2H4z"></path></svg>',
                                ),
                                onPressed: null,
                              ),
                              hintText: isTyping ? '' : 'ป้อนรหัสผ่านของคุณ',
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: width * 0.03,
                          bottom: height * 0.003,
                          top: height * 0.01,
                          right: width * 0.02,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ที่อยู่',
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!editInformation)
                        Container(
                          height: height * 0.08,
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: addressCtl,
                            keyboardType: TextInputType.multiline,
                            cursorColor: Colors.black,
                            maxLines: null, // เพื่อให้รองรับข้อความหลายบรรทัด
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: resultsResponseMemberBody[0].address,
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.015,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      if (editInformation)
                        Container(
                          height: height * 0.08,
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: addressCtl,
                            keyboardType: TextInputType.multiline,
                            cursorColor: Colors.black,
                            maxLines: null, // เพื่อให้รองรับข้อความหลายบรรทัด
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                iconSize: height * 0.03,
                                icon: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.045 7.401c.378-.378.586-.88.586-1.414s-.208-1.036-.586-1.414l-1.586-1.586c-.378-.378-.88-.586-1.414-.586s-1.036.208-1.413.585L4 13.585V18h4.413L19.045 7.401zm-3-3 1.587 1.585-1.59 1.584-1.586-1.585 1.589-1.584zM6 16v-1.585l7.04-7.018 1.586 1.586L7.587 16H6zm-2 4h16v2H4z"></path></svg>',
                                ),
                                onPressed: null,
                              ),
                              hintText: isTyping
                                  ? ''
                                  : 'บ้านเลขที่, ซอย, หมู่, ถนน, แขวง/ตำบล,\n เขต/อำเภอ, จังหวัด, รหัสไปรษณีย์',
                              hintStyle: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color(0xff898989),
                              ),
                              constraints: BoxConstraints(
                                maxHeight: height * 0.05,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.04,
                                vertical: height * 0.015,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      if (!editInformation)
                        Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.03,
                            bottom: height * 0.002,
                            right: width * 0.02,
                            top: height * 0.008,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'สถานที่รับสินค้า',
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleMedium!.fontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (editInformation)
                        Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.03,
                            bottom: height * 0.002,
                            right: width * 0.02,
                            top: height * 0.008,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'สถานที่รับสินค้า',
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleMedium!.fontSize,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  sameLocationAaddressText.text =
                                      'เลือกตำแหน่ง';
                                  sameLocationAaddresstextShow.clear();
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.005,
                                  ),
                                  child: Text(
                                    'ล้าง',
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleMedium!.fontSize,
                                      color: const Color(0xfff44235),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!editInformation)
                        Container(
                          width: width,
                          height: height * 0.08,
                          decoration: BoxDecoration(
                            color: const Color(0xff8B8B8B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.string(
                                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 14c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2z"></path><path d="M11.42 21.814a.998.998 0 0 0 1.16 0C12.884 21.599 20.029 16.44 20 10c0-4.411-3.589-8-8-8S4 5.589 4 9.995c-.029 6.445 7.116 11.604 7.42 11.819zM12 4c3.309 0 6 2.691 6 6.005.021 4.438-4.388 8.423-6 9.73-1.611-1.308-6.021-5.294-6-9.735 0-3.309 2.691-6 6-6z"></path></svg>',
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      width * 0.65, // จำกัดความกว้างของข้อความ
                                ),
                                child: Text(
                                  context
                                      .read<Appdata>()
                                      .pickupLocations
                                      .pickupLocation,
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                    color:
                                        const Color.fromARGB(248, 61, 61, 61),
                                  ),
                                  maxLines:
                                      3, // จำกัดการแสดงผลให้อยู่ในบรรทัดเดียว
                                  overflow: TextOverflow
                                      .visible, // แสดงข้อความทั้งหมด
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (editInformation)
                        TextButton(
                          onPressed: () {
                            locationSelected();
                          },
                          style: TextButton.styleFrom(
                            fixedSize: Size(
                              width,
                              height * 0.08,
                            ),
                            backgroundColor: const Color(0xff8B8B8B),
                            elevation: 3, // เงาล่าง
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12), // มุมโค้งมน
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.string(
                                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 14c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2z"></path><path d="M11.42 21.814a.998.998 0 0 0 1.16 0C12.884 21.599 20.029 16.44 20 10c0-4.411-3.589-8-8-8S4 5.589 4 9.995c-.029 6.445 7.116 11.604 7.42 11.819zM12 4c3.309 0 6 2.691 6 6.005.021 4.438-4.388 8.423-6 9.73-1.611-1.308-6.021-5.294-6-9.735 0-3.309 2.691-6 6-6z"></path></svg>',
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      width * 0.65, // จำกัดความกว้างของข้อความ
                                ),
                                child: Text(
                                  sameLocationAaddressText.text,
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleMedium!.fontSize,
                                    color: Colors.black,
                                  ),
                                  maxLines:
                                      3, // จำกัดการแสดงผลให้อยู่ในบรรทัดเดียว
                                  overflow: TextOverflow
                                      .visible, // แสดงข้อความทั้งหมด
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: height * 0.02),
                      if (!editInformation)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              editInformation = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              width * 0.4,
                              height * 0.05,
                            ),
                            backgroundColor: const Color(0xffFEF7E7),
                            elevation: 3, //เงาล่าง
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(24), // มุมโค้งมน
                            ),
                          ),
                          child: Text(
                            "แก้ไข",
                            style: TextStyle(
                              fontSize: Get.textTheme.titleLarge!.fontSize,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      if (editInformation)
                        ElevatedButton(
                          onPressed: editProfile,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              width * 0.4,
                              height * 0.05,
                            ),
                            backgroundColor: const Color(0xffFEF7E7),
                            elevation: 3, //เงาล่าง
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(24), // มุมโค้งมน
                            ),
                          ),
                          child: Text(
                            "บันทึก",
                            style: TextStyle(
                              fontSize: Get.textTheme.titleLarge!.fontSize,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      SizedBox(height: height * 0.04),
                      InkWell(
                        onTap: () {
                          Get.to(() => const LoginPage());
                        },
                        child: Text(
                          "ออกจากระบบ",
                          style: TextStyle(
                            fontSize: Get.textTheme.titleMedium!.fontSize,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  void editProfile() async {
    setState(() {
      editInformation = false;
    });

    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    //ถ้าหากมีการเปลี่ยนรูป
    String downloadUrl = "";
    if (savedFile != null) {
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
      try {
        // สร้างอ้างอิงไปยัง Firebase Storage
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'uploads/${DateTime.now().millisecondsSinceEpoch}_${savedFile!.path.split('/').last}');

        // อัพโหลดไฟล์และรอจนกว่าจะเสร็จสิ้น
        UploadTask uploadTask = storageReference.putFile(savedFile!);
        TaskSnapshot taskSnapshot = await uploadTask;

        // รับ URL ของรูปที่อัพโหลดสำเร็จ
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
        // ลบรูปเดิมหากมี
        if (resultsResponseMemberBody[0].imageMember.isNotEmpty) {
          Reference oldImageRef = FirebaseStorage.instance
              .refFromURL(resultsResponseMemberBody[0].imageMember);
          await oldImageRef.delete();
        }
      } catch (e) {
      } finally {
        // ปิด Loading Indicator
        Get.back();
      }
    }
    UpdateMemberPutRequest jsonUpdateMember = UpdateMemberPutRequest(
      name: nameCth.text.isNotEmpty
          ? nameCth.text
          : resultsResponseMemberBody[0].name,
      password: passwordCth.text.isNotEmpty
          ? passwordCth.text
          : resultsResponseMemberBody[0].password,
      address: addressCtl.text.isNotEmpty
          ? addressCtl.text
          : resultsResponseMemberBody[0].address,
      gps: latlng.text.isNotEmpty
          ? latlng.text
          : resultsResponseMemberBody[0].gps,
      imageMember: savedFile != null
          ? downloadUrl
          : resultsResponseMemberBody[0].imageMember,
    );

    var responsePutJsonUpdateMember = await http.put(
      Uri.parse(
          "$url/member/updatemember/${resultsResponseMemberBody[0].phone}"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: updateMemberPutRequestToJson(jsonUpdateMember),
    );

    if (responsePutJsonUpdateMember.statusCode == 200) {
      setState(() {
        savedFile = null;
        loadDataAsync();
      });
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
              'แก้ไขข้อมูลสำเร็จ!',
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

  void locationSelected() async {
    // ใช้ width สำหรับ horizontal
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    double height = MediaQuery.of(context).size.height;

    var config = await Configuration.getConfig();
    var apiKey = config['apiKey'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // ไม่สามารถปิดได้ด้วยการลาก
      enableDrag: false, // ปิดการลาก
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.015,
          ),
          child: Container(
            height: height * 0.9,
            child: FutureBuilder(
              future: _determinePosition(), // ดึงตำแหน่งปัจจุบัน
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                Position position = snapshot.data!;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.01,
                              vertical: height * 0.005,
                            ),
                            child: SvgPicture.string(
                              '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12.707 17.293 8.414 13H18v-2H8.414l4.293-4.293-1.414-1.414L4.586 12l6.707 6.707z"></path></svg>',
                              height: height * 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ที่อยู่',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            sameLocationAaddressText.text = 'เลือกตำแหน่ง';
                            sameLocationAaddresstextShow.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ล้าง',
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                                color: const Color(0xfff44235),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      height: height * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xffE2E2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: sameLocationAaddresstextShow,
                        enabled: true,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        maxLines: null, // รองรับหลายบรรทัด
                        decoration: InputDecoration(
                          hintText:
                              'บ้านเลขที่, ซอย, หมู่, ถนน, แขวง/ตำบล, เขต/อำเภอ, จังหวัด, รหัสไปรษณีย์',
                          hintStyle: TextStyle(
                            fontSize: Get.textTheme.titleSmall!.fontSize,
                            color: const Color.fromARGB(255, 115, 115, 115),
                          ),
                          constraints: BoxConstraints(
                            maxHeight: height * 0.05,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.015,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Expanded(
                      child: PlacePicker(
                        apiKey: apiKey, // ใช้ API Key ของคุณ
                        onPlacePicked: (result) {
                          sameLocationAaddresstextShow.text =
                              result.formattedAddress.toString();
                          sameLocationAaddressText.text =
                              result.formattedAddress.toString();
                          latlng.text = result.geometry!.location.toString();
                          setState(() {});
                        },
                        initialPosition: LatLng(position.latitude,
                            position.longitude), // ใช้ตำแหน่งปัจจุบัน
                        useCurrentLocation: true,
                        automaticallyImplyAppBarLeading: false, // ปิดลูกศรกลับ
                        searchForInitialValue: false, // ปิดการค้นหา
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
