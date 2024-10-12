import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/request/updateRiderPutRequest.dart';
import 'package:raidely/models/response/byPhoneRiderGetResponse.dart';
import 'package:raidely/pages/login.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;

class ProfileRiderPage extends StatefulWidget {
  const ProfileRiderPage({super.key});

  @override
  State<ProfileRiderPage> createState() => _ProfileRiderPageState();
}

class _ProfileRiderPageState extends State<ProfileRiderPage> {
  late Future<void> loadData;
  TextEditingController phoneCth = TextEditingController();
  TextEditingController nameCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  TextEditingController plateCth = TextEditingController();
  bool isTyping = false;
  bool sameLocationAaddress = false;
  bool editInformation = false;
  bool openInfoCarRegistration = true;
  late List<ByPhoneRiderGetResponse> resultsResponseRiderBody = [];
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;
  final box = GetStorage();

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
    setState(() {
      phoneCth.text = resultsResponseRiderBody[0].phone;
      nameCth.text = resultsResponseRiderBody[0].name;
      passwordCth.text = resultsResponseRiderBody[0].password;
      plateCth.text = resultsResponseRiderBody[0].plate;
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
                                color: const Color.fromARGB(255, 203, 203, 203),
                                items: [
                                  PopupMenuItem(
                                    value: 'แกลลอรี่',
                                    child: Text(
                                      'เลือกจากแกลลอรี่',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'เลือกไฟล์',
                                    child: Text(
                                      'เลือกไฟล์',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'ถ่ายรูป',
                                    child: Text(
                                      'ถ่ายรูป',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
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
                                            child: resultsResponseRiderBody[0]
                                                        .imageRider ==
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
                                                          height: height * 0.1,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xffd9d9d9),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 0,
                                                          child:
                                                              SvgPicture.string(
                                                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                                            height:
                                                                height * 0.07,
                                                            color: Colors.grey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Image.network(
                                                    resultsResponseRiderBody[0]
                                                        .imageRider,
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
                            child: resultsResponseRiderBody[0].imageRider == '-'
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
                                    resultsResponseRiderBody[0].imageRider,
                                    height: height * 0.1,
                                    width: width * 0.22,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                    SizedBox(height: height * 0.02),
                    Text(
                      resultsResponseRiderBody[0].name,
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
                                  fontSize: Get.textTheme.titleMedium!.fontSize,
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
                          hintText: resultsResponseRiderBody[0].phone,
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
                                  fontSize: Get.textTheme.titleMedium!.fontSize,
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
                            hintText: resultsResponseRiderBody[0].name,
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
                                  fontSize: Get.textTheme.titleMedium!.fontSize,
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
                            hintText: resultsResponseRiderBody[0]
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
                        bottom: height * 0.002,
                        top: height * 0.008,
                        right: width * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ทะเบียนรถ',
                                style: TextStyle(
                                  fontSize: Get.textTheme.titleMedium!.fontSize,
                                ),
                              ),
                            ],
                          ),
                          if (editInformation)
                            Row(
                              children: [
                                if (!openInfoCarRegistration)
                                  Text(
                                    '1กร 7369 ร้อยเอ็ด ',
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.labelMedium!.fontSize,
                                      color: const Color(0xffB1B1B1),
                                    ),
                                  ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      openInfoCarRegistration =
                                          !openInfoCarRegistration;
                                    });
                                  },
                                  child: SvgPicture.string(
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                    color: const Color(0xffB1B1B1),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (!editInformation)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffE2E2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              enabled: false,
                              obscureText: false,
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                hintText: resultsResponseRiderBody[0].plate,
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
                          ],
                        ),
                      ),
                    if (editInformation)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffE2E2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: plateCth,
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.black,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9ก-๙]'),
                                ), // อนุญาตเฉพาะตัวอักษรและตัวเลข
                              ],
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  iconSize: height * 0.03,
                                  icon: SvgPicture.string(
                                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M19.045 7.401c.378-.378.586-.88.586-1.414s-.208-1.036-.586-1.414l-1.586-1.586c-.378-.378-.88-.586-1.414-.586s-1.036.208-1.413.585L4 13.585V18h4.413L19.045 7.401zm-3-3 1.587 1.585-1.59 1.584-1.586-1.585 1.589-1.584zM6 16v-1.585l7.04-7.018 1.586 1.586L7.587 16H6zm-2 4h16v2H4z"></path></svg>',
                                  ),
                                  onPressed: null,
                                ),
                                hintText: isTyping ? '' : 'ป้อนทะเบียนรถของคุณ',
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
        },
      ),
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
            'shippingListUploadImage/${DateTime.now().millisecondsSinceEpoch}_${savedFile!.path.split('/').last}');

        // อัพโหลดไฟล์และรอจนกว่าจะเสร็จสิ้น
        UploadTask uploadTask = storageReference.putFile(savedFile!);
        TaskSnapshot taskSnapshot = await uploadTask;

        // รับ URL ของรูปที่อัพโหลดสำเร็จ
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
        // ลบรูปเดิมหากมี
        if (resultsResponseRiderBody[0].imageRider.isNotEmpty) {
          Reference oldImageRef = FirebaseStorage.instance
              .refFromURL(resultsResponseRiderBody[0].imageRider);
          await oldImageRef.delete();
        }
      } catch (e) {
      } finally {
        // ปิด Loading Indicator
        Get.back();
      }
    }
    UpdateRiderPutRequest jsonUpdateRider = UpdateRiderPutRequest(
      name: nameCth.text.isNotEmpty
          ? nameCth.text
          : resultsResponseRiderBody[0].name,
      password: passwordCth.text.isNotEmpty
          ? passwordCth.text
          : resultsResponseRiderBody[0].password,
      plate: plateCth.text.isNotEmpty
          ? plateCth.text
          : resultsResponseRiderBody[0].plate,
      imageRider: savedFile != null
          ? downloadUrl
          : resultsResponseRiderBody[0].imageRider,
    );

    var responsePutJsonUpdateRider = await http.put(
      Uri.parse("$url/rider/updaterider/${resultsResponseRiderBody[0].phone}"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: updateRiderPutRequestToJson(jsonUpdateRider),
    );

    if (responsePutJsonUpdateRider.statusCode == 200) {
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
}
