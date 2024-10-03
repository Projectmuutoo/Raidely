import 'dart:async';
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
import 'package:raidely/config/config.dart';
import 'package:raidely/models/request/registerMemberPostRequest.dart';
import 'package:raidely/models/request/registerRiderPostRequest.dart';
import 'package:raidely/models/response/memberAllGetResponse.dart';
import 'package:raidely/models/response/riderAllGetResponse.dart';
import 'package:raidely/pages/login.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String textPhoneWarningIsEmpty = '898989';
  String textNameWarningIsEmpty = '898989';
  String textPasswordWarningIsEmpty = '898989';
  String textPasswordCheckWarningIsEmpty = '898989';
  String textCarRegistrationWarningIsEmpty = '898989';
  String textAddressWarningIsEmpty = '898989';
  String textsameLocationAaddressWarningIsEmpty = '898989';
  bool checkTextPhoneWarningIsEmpty = false;
  bool checkTextNameWarningIsEmpty = false;
  bool checkTextPasswordWarningIsEmpty = false;
  bool checkTextPasswordCheckWarningIsEmpty = false;
  bool checkTextCarRegistrationWarningIsEmpty = false;
  bool checkTextAddressWarningIsEmpty = false;
  bool checkTextsameLocationAaddressWarningIsEmpty = false;
  TextEditingController phoneCth = TextEditingController();
  TextEditingController nameCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  TextEditingController passwordCheckCtl = TextEditingController();
  TextEditingController carRegistrationCtl = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  TextEditingController sameLocationAaddressText = TextEditingController();
  TextEditingController latlng = TextEditingController();
  TextEditingController sameLocationAaddresstextShow = TextEditingController();
  bool selectType = false;
  String selectedType = '';
  bool isTyping = false;
  bool _isCheckedPassword = true;
  bool _isCheckedPassword2 = true;
  bool openInfoCarRegistration = true;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? savedFile;

  @override
  void initState() {
    sameLocationAaddressText.text = 'เลือกตำแหน่ง';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

    Widget buildOption(String type, String image) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            selectType = true;
            selectedType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          fixedSize: Size(width * 0.45, height * 0.26),
          backgroundColor: const Color(0xffFEF7E7),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$image.png',
              height: height * 0.16,
            ),
            Text(
              type,
              style: TextStyle(
                fontSize: Get.textTheme.headlineSmall!.fontSize,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: selectType
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectType = false;
                    selectedType = '';
                    textPhoneWarningIsEmpty = '898989';
                    textNameWarningIsEmpty = '898989';
                    textPasswordWarningIsEmpty = '898989';
                    textPasswordCheckWarningIsEmpty = '898989';
                    textCarRegistrationWarningIsEmpty = '898989';
                    textAddressWarningIsEmpty = '898989';
                    textsameLocationAaddressWarningIsEmpty = '898989';
                    checkTextPhoneWarningIsEmpty = false;
                    checkTextNameWarningIsEmpty = false;
                    checkTextPasswordWarningIsEmpty = false;
                    checkTextPasswordCheckWarningIsEmpty = false;
                    checkTextCarRegistrationWarningIsEmpty = false;
                    checkTextAddressWarningIsEmpty = false;
                    checkTextsameLocationAaddressWarningIsEmpty = false;
                  });
                },
              )
            : null,
      ),
      body: Center(
        child: selectType
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1,
                      ),
                      child: Column(
                        children: [
                          InkWell(
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
                              width: width * 0.25,
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
                                          child: SvgPicture.string(
                                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                            height: height * 0.07,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Positioned(
                                          left: width * 0.02,
                                          right: width * 0.02,
                                          bottom: 0,
                                          top: 0,
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
                          ),
                          SizedBox(height: height * 0.005),
                          Text(
                            'สมัครเป็น$selectedType',
                            style: TextStyle(
                              fontSize: Get.textTheme.headlineSmall!.fontSize,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.03,
                                  bottom: height * 0.002,
                                  top: height * 0.008,
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
                                    Text(
                                      ' *',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleMedium!.fontSize,
                                        color: Colors.red,
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
                            child: Stack(
                              children: [
                                TextField(
                                  controller: phoneCth,
                                  keyboardType: TextInputType.phone,
                                  cursorColor: Colors.black,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: isTyping
                                        ? ''
                                        : 'ป้อนหมายเลขโทรศัพท์ของคุณ',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleSmall!.fontSize,
                                      color: Color(
                                        int.parse(
                                            '0xff$textPhoneWarningIsEmpty'),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: height * 0.05,
                                    ),
                                    contentPadding:
                                        !checkTextPhoneWarningIsEmpty
                                            ? EdgeInsets.symmetric(
                                                horizontal: width * 0.04,
                                              )
                                            : EdgeInsets.symmetric(
                                                horizontal: width * 0.08,
                                              ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                !checkTextPhoneWarningIsEmpty
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: width * 0.02,
                                        child: SvgPicture.string(
                                          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                          width: width * 0.025,
                                          height: height * 0.025,
                                          color: Colors.red,
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.03,
                                  bottom: height * 0.002,
                                  top: height * 0.008,
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
                                    Text(
                                      ' *',
                                      style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                          color: Colors.red),
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
                            child: Stack(
                              children: [
                                TextField(
                                  controller: nameCth,
                                  keyboardType: TextInputType.name,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: isTyping ? '' : 'ป้อนชื่อของคุณ',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleSmall!.fontSize,
                                      color: Color(
                                        int.parse(
                                            '0xff$textNameWarningIsEmpty'),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: height * 0.05,
                                    ),
                                    contentPadding: !checkTextNameWarningIsEmpty
                                        ? EdgeInsets.symmetric(
                                            horizontal: width * 0.04,
                                          )
                                        : EdgeInsets.symmetric(
                                            horizontal: width * 0.08,
                                          ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                !checkTextNameWarningIsEmpty
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: width * 0.02,
                                        child: SvgPicture.string(
                                          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                          width: width * 0.025,
                                          height: height * 0.025,
                                          color: Colors.red,
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.03,
                                    bottom: height * 0.002,
                                    top: height * 0.008,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'รหัสผ่าน',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        ' *',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffE2E2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: passwordCth,
                                  obscureText: _isCheckedPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      iconSize: height * 0.03,
                                      icon: Icon(
                                        _isCheckedPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isCheckedPassword =
                                              !_isCheckedPassword;
                                        });
                                      },
                                    ),
                                    hintText:
                                        isTyping ? '' : 'ป้อนรหัสผ่านของคุณ',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleSmall!.fontSize,
                                      color: Color(
                                        int.parse(
                                            '0xff$textPasswordWarningIsEmpty'),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: height * 0.05,
                                    ),
                                    contentPadding:
                                        !checkTextPasswordWarningIsEmpty
                                            ? EdgeInsets.symmetric(
                                                horizontal: width * 0.04,
                                              )
                                            : EdgeInsets.symmetric(
                                                horizontal: width * 0.08,
                                              ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                !checkTextPasswordWarningIsEmpty
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: width * 0.02,
                                        child: SvgPicture.string(
                                          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                          width: width * 0.025,
                                          height: height * 0.025,
                                          color: Colors.red,
                                        ),
                                      )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                    left: width * 0.03,
                                    bottom: height * 0.002,
                                    top: height * 0.008,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'ยืนยันรหัสผ่าน',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        ' *',
                                        style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: Colors.red),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffE2E2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: passwordCheckCtl,
                                  obscureText: _isCheckedPassword2,
                                  keyboardType: TextInputType.visiblePassword,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      iconSize: height * 0.03,
                                      icon: Icon(
                                        _isCheckedPassword2
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isCheckedPassword2 =
                                              !_isCheckedPassword2;
                                        });
                                      },
                                    ),
                                    hintText: isTyping
                                        ? ''
                                        : 'ป้อนยืนยันรหัสผ่านของคุณ',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleSmall!.fontSize,
                                      color: Color(
                                        int.parse(
                                            '0xff$textPasswordCheckWarningIsEmpty'),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight: height * 0.05,
                                    ),
                                    contentPadding:
                                        !checkTextPasswordCheckWarningIsEmpty
                                            ? EdgeInsets.symmetric(
                                                horizontal: width * 0.04,
                                              )
                                            : EdgeInsets.symmetric(
                                                horizontal: width * 0.08,
                                              ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                !checkTextPasswordCheckWarningIsEmpty
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: width * 0.02,
                                        child: SvgPicture.string(
                                          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                          width: width * 0.025,
                                          height: height * 0.025,
                                          color: Colors.red,
                                        ),
                                      )
                              ],
                            ),
                          ),
                          if (selectedType == 'ไรเดอร์')
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.03,
                                bottom: height * 0.002,
                                top: height * 0.008,
                                right: width * 0.02,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'ทะเบียนรถ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        ' *',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (!openInfoCarRegistration)
                                        Text(
                                          '1กร 7369 ร้อยเอ็ด ',
                                          style: TextStyle(
                                            fontSize: Get.textTheme.labelMedium!
                                                .fontSize,
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
                          if (selectedType == 'ไรเดอร์')
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffE2E2E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: carRegistrationCtl,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.black,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9ก-๙]'),
                                      ), // อนุญาตเฉพาะตัวอักษรและตัวเลข
                                    ],
                                    decoration: InputDecoration(
                                      hintText:
                                          isTyping ? '' : 'ป้อนทะเบียนรถของคุณ',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleSmall!.fontSize,
                                        color: Color(
                                          int.parse(
                                              '0xff$textCarRegistrationWarningIsEmpty'),
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        maxHeight: height * 0.05,
                                      ),
                                      contentPadding:
                                          !checkTextCarRegistrationWarningIsEmpty
                                              ? EdgeInsets.symmetric(
                                                  horizontal: width * 0.04,
                                                )
                                              : EdgeInsets.symmetric(
                                                  horizontal: width * 0.08,
                                                ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  !checkTextCarRegistrationWarningIsEmpty
                                      ? const SizedBox.shrink()
                                      : Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: width * 0.02,
                                          child: SvgPicture.string(
                                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                            width: width * 0.025,
                                            height: height * 0.025,
                                            color: Colors.red,
                                          ),
                                        )
                                ],
                              ),
                            ),
                          if (selectedType == 'ผู้ใช้')
                            Padding(
                                padding: EdgeInsets.only(
                                  left: width * 0.03,
                                  bottom: height * 0.003,
                                  top: height * 0.008,
                                  right: width * 0.02,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ที่อยู่',
                                          style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                          ),
                                        ),
                                        Text(
                                          ' *',
                                          style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          if (selectedType == 'ผู้ใช้')
                            Stack(
                              children: [
                                Container(
                                  height: height * 0.08,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE2E2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: addressCtl,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.black,
                                    maxLines: null, // รองรับหลายบรรทัด
                                    decoration: InputDecoration(
                                      hintText: isTyping
                                          ? ''
                                          : 'บ้านเลขที่, ซอย, หมู่, ถนน, แขวง/ตำบล, เขต/อำเภอ, จังหวัด, รหัสไปรษณีย์',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleSmall!.fontSize,
                                        color: Color(
                                          int.parse(
                                              '0xff$textAddressWarningIsEmpty'),
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        maxHeight: height * 0.05,
                                      ),
                                      contentPadding:
                                          !checkTextAddressWarningIsEmpty
                                              ? EdgeInsets.symmetric(
                                                  horizontal: width * 0.04,
                                                  vertical: height * 0.015,
                                                )
                                              : EdgeInsets.only(
                                                  left: width * 0.08,
                                                  right: width * 0.02,
                                                  top: height * 0.015,
                                                  bottom: height * 0.015,
                                                ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                !checkTextAddressWarningIsEmpty
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: width * 0.02,
                                        child: SvgPicture.string(
                                          '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                          width: width * 0.025,
                                          height: height * 0.025,
                                          color: Colors.red,
                                        ),
                                      ),
                              ],
                            ),
                          if (selectedType == 'ผู้ใช้')
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.03,
                                bottom: height * 0.002,
                                right: width * 0.02,
                                top: height * 0.008,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'สถานที่รับสินค้า ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        ' *',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                          color: Colors.red,
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
                                          fontSize: Get
                                              .textTheme.titleMedium!.fontSize,
                                          color: const Color(0xfff44235),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (selectedType == 'ผู้ใช้')
                            Stack(
                              children: [
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
                                      borderRadius: BorderRadius.circular(
                                          12), // มุมโค้งมน
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
                                          maxWidth: width *
                                              0.65, // จำกัดความกว้างของข้อความ
                                        ),
                                        child: Text(
                                          sameLocationAaddressText.text,
                                          style: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color:
                                                !checkTextsameLocationAaddressWarningIsEmpty
                                                    ? Colors.black
                                                    : Color(
                                                        int.parse(
                                                          '0xff$textsameLocationAaddressWarningIsEmpty',
                                                        ),
                                                      ),
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
                                if (checkTextsameLocationAaddressWarningIsEmpty)
                                  Positioned(
                                    top: 0,
                                    bottom: 0,
                                    left: width * 0.02,
                                    child: SvgPicture.string(
                                      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10 10-4.486 10-10S17.514 2 12 2zm0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8 8 3.589 8 8-3.589 8-8 8z"></path><path d="M11 11h2v6h-2zm0-4h2v2h-2z"></path></svg>',
                                      width: width * 0.025,
                                      height: height * 0.025,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          if (selectedType == 'ไรเดอร์')
                            SizedBox(height: height * 0.03),
                          if (selectedType == 'ผู้ใช้')
                            SizedBox(height: height * 0.01),
                          // ปุ่มสมัคร
                          ElevatedButton(
                            onPressed: () => register(selectedType),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                width * 0.7,
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
                              "สมัครสมาชิก",
                              style: TextStyle(
                                fontSize: Get.textTheme.titleLarge!.fontSize,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          if (selectedType == 'ไรเดอร์')
                            SizedBox(height: height * 0.04),
                          if (selectedType == 'ผู้ใช้')
                            SizedBox(height: height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: width * 0.01,
                                ),
                                child: Text(
                                  "มีบัญชีอยู่แล้ว?",
                                  style: TextStyle(
                                    fontSize:
                                        Get.textTheme.titleSmall!.fontSize,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: login,
                                child: SizedBox(
                                  child: Text(
                                    "เข้าสู่ระบบ",
                                    style: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleSmall!.fontSize,
                                      color: const Color(0xff4696C1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedType == 'ไรเดอร์')
                            SizedBox(height: height * 0.03),
                          if (selectedType == 'ผู้ใช้')
                            SizedBox(height: height * 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ) // แสดงหน้าของที่เลือก
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'โปรดเลือกประเภทผู้ใช้',
                      style: TextStyle(
                        fontSize: Get.textTheme.headlineSmall!.fontSize,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    buildOption("ไรเดอร์", "rider"),
                    SizedBox(height: height * 0.05),
                    Text(
                      'หรือ',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    buildOption("ผู้ใช้", "user"),
                  ],
                ),
              ),
      ),
    );
  }
  //-------------------------------------------------------------------------

  void register(String selectedType) async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var responseMember = await http.get(Uri.parse('$url/member'));
    var responseRider = await http.get(Uri.parse('$url/rider'));
    var memberAllResponse = memberAllGetResponseFromJson(responseMember.body);
    var riderAllResponse = riderAllGetResponseFromJson(responseRider.body);
    var phoneMembers = memberAllResponse.map((value) => value.phone).toList();
    var phoneRiders = riderAllResponse.map((value) => value.phone).toList();
    //ถ้าหากสมัครเป็นไรเดอร์
    if (selectedType == 'ไรเดอร์') {
      if (phoneCth.text.isNotEmpty &&
          nameCth.text.isNotEmpty &&
          passwordCth.text.isNotEmpty &&
          passwordCheckCtl.text.isNotEmpty &&
          carRegistrationCtl.text.isNotEmpty) {
        //แสดงสีป้อนข้อมูลเดิม
        setState(() {
          textPhoneWarningIsEmpty = '898989';
          textNameWarningIsEmpty = '898989';
          textPasswordWarningIsEmpty = '898989';
          textPasswordCheckWarningIsEmpty = '898989';
          textCarRegistrationWarningIsEmpty = '898989';
          textAddressWarningIsEmpty = '898989';
          checkTextPhoneWarningIsEmpty = false;
          checkTextNameWarningIsEmpty = false;
          checkTextPasswordWarningIsEmpty = false;
          checkTextPasswordCheckWarningIsEmpty = false;
          checkTextCarRegistrationWarningIsEmpty = false;
          checkTextAddressWarningIsEmpty = false;
        });
        //ถ้าเบอร์โทรถูกต้อง
        if (phoneCth.text.length == 10) {
          //ถ้าหาก phoneMembers,phoneRiders ตรงกันกับที่ user พิมมา แสดงว่าเบอร์ซ้ำสมัครบ่ได่
          if (phoneMembers.contains(phoneCth.text) ||
              phoneRiders.contains(phoneCth.text)) {
            Get.defaultDialog(
              title: "",
              titlePadding: EdgeInsets.zero,
              content: Column(
                children: [
                  Image.asset(
                    'assets/images/warning.png',
                    width: MediaQuery.of(context).size.width * 0.16,
                    height: MediaQuery.of(context).size.width * 0.16,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                  Text(
                    'ไม่สามารถสมัครสมาชิกได้!',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'เนื่องจากมีเบอร์ผู้ใช้นี้แล้ว.',
                    style: TextStyle(
                      fontSize: Get.textTheme.labelMedium!.fontSize,
                      color: Colors.red,
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
          } else {
            //ถ้า password ตรงกัน
            if (passwordCth.text == passwordCheckCtl.text) {
              //ถ้าหากป้อนทะเบียนรถถูก field นั้นต้องมีตัวเลข และ ตัวอักษร
              if (RegExp(r'[0-9]').hasMatch(carRegistrationCtl.text) &&
                  RegExp(r'[ก-ฮ]').hasMatch(carRegistrationCtl.text)) {
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
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03),
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
                    Reference storageReference = FirebaseStorage.instance
                        .ref()
                        .child(
                            'uploads/${DateTime.now().millisecondsSinceEpoch}_${savedFile!.path.split('/').last}');

                    // อัพโหลดไฟล์และรอจนกว่าจะเสร็จสิ้น
                    UploadTask uploadTask =
                        storageReference.putFile(savedFile!);
                    TaskSnapshot taskSnapshot = await uploadTask;

                    // รับ URL ของรูปที่อัพโหลดสำเร็จ
                    downloadUrl = await taskSnapshot.ref.getDownloadURL();
                  } catch (e) {
                  } finally {
                    // ปิด Loading Indicator
                    Get.back();
                  }
                }
                RegisterRiderPostRequest jsonRegisterRider =
                    RegisterRiderPostRequest(
                  name: nameCth.text,
                  phone: phoneCth.text,
                  password: passwordCth.text,
                  plate: carRegistrationCtl.text,
                  imageRider: savedFile != null ? downloadUrl : "-",
                );

                var responsePostJsonRegisterRider = await http.post(
                  Uri.parse("$url/rider/register"),
                  headers: {"Content-Type": "application/json; charset=utf-8"},
                  body: registerRiderPostRequestToJson(jsonRegisterRider),
                );

                if (responsePostJsonRegisterRider.statusCode == 200) {
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
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03),
                        Text(
                          'สมัครสมาชิกสำเร็จ!',
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
                          Get.to(() => const LoginPage());
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
              } else {
                Get.defaultDialog(
                  title: "",
                  titlePadding: EdgeInsets.zero,
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
                        'ทะเบียนรถของคุณไม่ถูกต้อง!',
                        style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.02),
                      Text(
                        'โปรดตรวจสอทะเบียนรถของท่านอีกครั้ง.',
                        style: TextStyle(
                          fontSize: Get.textTheme.titleSmall!.fontSize,
                          color: Colors.red,
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
            } else {
              Get.defaultDialog(
                title: "",
                titlePadding: EdgeInsets.zero,
                content: Column(
                  children: [
                    Image.asset(
                      'assets/images/warning.png',
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.width * 0.16,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                    Text(
                      'รหัสผ่านของคุณไม่ตรงกัน!',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      'โปรดตรวจสอบรหัสผ่านของท่านอีกครั้ง.',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleSmall!.fontSize,
                        color: Colors.red,
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
        } else {
          Get.defaultDialog(
            title: "",
            titlePadding: EdgeInsets.zero,
            content: Column(
              children: [
                Image.asset(
                  'assets/images/warning.png',
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                Text(
                  'เบอร์โทรศัพท์ไม่ถูกต้อง!',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                Text(
                  'โปรดตรวจสอบเบอร์โทรศัพท์ของท่านอีกครั้ง.',
                  style: TextStyle(
                    fontSize: Get.textTheme.labelMedium!.fontSize,
                    color: Colors.red,
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
      } else {
        //แสดงสีป้อนข้อมูล
        if (phoneCth.text.isEmpty) {
          setState(() {
            textPhoneWarningIsEmpty = 'ff0000';
            checkTextPhoneWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPhoneWarningIsEmpty = '898989';
            checkTextPhoneWarningIsEmpty = false;
          });
        }
        if (nameCth.text.isEmpty) {
          setState(() {
            textNameWarningIsEmpty = 'ff0000';
            checkTextNameWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textNameWarningIsEmpty = '898989';
            checkTextNameWarningIsEmpty = false;
          });
        }
        if (passwordCth.text.isEmpty) {
          setState(() {
            textPasswordWarningIsEmpty = 'ff0000';
            checkTextPasswordWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPasswordWarningIsEmpty = '898989';
            checkTextPasswordWarningIsEmpty = false;
          });
        }
        if (passwordCheckCtl.text.isEmpty) {
          setState(() {
            textPasswordCheckWarningIsEmpty = 'ff0000';
            checkTextPasswordCheckWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPasswordCheckWarningIsEmpty = '898989';
            checkTextPasswordCheckWarningIsEmpty = false;
          });
        }
        if (carRegistrationCtl.text.isEmpty) {
          setState(() {
            textCarRegistrationWarningIsEmpty = 'ff0000';
            checkTextCarRegistrationWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textCarRegistrationWarningIsEmpty = '898989';
            checkTextCarRegistrationWarningIsEmpty = false;
          });
        }
      }
    }
    if (selectedType == 'ผู้ใช้') {
      if (phoneCth.text.isNotEmpty &&
          nameCth.text.isNotEmpty &&
          passwordCth.text.isNotEmpty &&
          passwordCheckCtl.text.isNotEmpty &&
          addressCtl.text.isNotEmpty &&
          sameLocationAaddressText.text.isNotEmpty) {
        //แสดงสีป้อนข้อมูลเดิม
        setState(() {
          textPhoneWarningIsEmpty = '898989';
          textNameWarningIsEmpty = '898989';
          textPasswordWarningIsEmpty = '898989';
          textPasswordCheckWarningIsEmpty = '898989';
          textCarRegistrationWarningIsEmpty = '898989';
          textAddressWarningIsEmpty = '898989';
          textsameLocationAaddressWarningIsEmpty = '898989';
          checkTextPhoneWarningIsEmpty = false;
          checkTextNameWarningIsEmpty = false;
          checkTextPasswordWarningIsEmpty = false;
          checkTextPasswordCheckWarningIsEmpty = false;
          checkTextCarRegistrationWarningIsEmpty = false;
          checkTextAddressWarningIsEmpty = false;
          checkTextsameLocationAaddressWarningIsEmpty = false;
        });

        if (sameLocationAaddressText.text == 'เลือกตำแหน่ง') {
          textsameLocationAaddressWarningIsEmpty = 'ff0000';
          checkTextsameLocationAaddressWarningIsEmpty = true;
          return;
        }

        //ถ้าเบอร์โทรถูกต้อง
        if (phoneCth.text.length == 10) {
          //ถ้าหาก phoneMembers,phoneRiders ตรงกันกับที่ user พิมมา แสดงว่าเบอร์ซ้ำสมัครบ่ได่
          if (phoneMembers.contains(phoneCth.text) ||
              phoneRiders.contains(phoneCth.text)) {
            Get.defaultDialog(
              title: "",
              titlePadding: EdgeInsets.zero,
              content: Column(
                children: [
                  Image.asset(
                    'assets/images/warning.png',
                    width: MediaQuery.of(context).size.width * 0.16,
                    height: MediaQuery.of(context).size.width * 0.16,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                  Text(
                    'ไม่สามารถสมัครสมาชิกได้!',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                  Text(
                    'เนื่องจากมีเบอร์ผู้ใช้นี้แล้ว.',
                    style: TextStyle(
                      fontSize: Get.textTheme.labelMedium!.fontSize,
                      color: Colors.red,
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
          } else {
            late RegisterMemberPostRequest jsonRegisterMember;
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
              } catch (e) {
              } finally {
                // ปิด Loading Indicator
                Get.back();
              }
            }
            //ถ้า password ตรงกัน
            if (passwordCth.text == passwordCheckCtl.text) {
              jsonRegisterMember = RegisterMemberPostRequest(
                name: nameCth.text,
                phone: phoneCth.text,
                password: passwordCth.text,
                address: addressCtl.text,
                gps: latlng.text,
                imageMember: savedFile != null ? downloadUrl : "-",
              );

              var responsePostJsonRegisterMember = await http.post(
                Uri.parse("$url/member/register"),
                headers: {"Content-Type": "application/json; charset=utf-8"},
                body: registerMemberPostRequestToJson(jsonRegisterMember),
              );

              if (responsePostJsonRegisterMember.statusCode == 200) {
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
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.03),
                      Text(
                        'สมัครสมาชิกสำเร็จ!',
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
                        Get.to(() => const LoginPage());
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
            } else {
              Get.defaultDialog(
                title: "",
                titlePadding: EdgeInsets.zero,
                content: Column(
                  children: [
                    Image.asset(
                      'assets/images/warning.png',
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.width * 0.16,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                    Text(
                      'รหัสผ่านของคุณไม่ตรงกัน!',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      'โปรดตรวจสอบรหัสผ่านของท่านอีกครั้ง.',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleSmall!.fontSize,
                        color: Colors.red,
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
        } else {
          Get.defaultDialog(
            title: "",
            titlePadding: EdgeInsets.zero,
            content: Column(
              children: [
                Image.asset(
                  'assets/images/warning.png',
                  width: MediaQuery.of(context).size.width * 0.16,
                  height: MediaQuery.of(context).size.width * 0.16,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                Text(
                  'เบอร์โทรศัพท์ไม่ถูกต้อง!',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                Text(
                  'โปรดตรวจสอบเบอร์โทรศัพท์ของท่านอีกครั้ง.',
                  style: TextStyle(
                    fontSize: Get.textTheme.labelMedium!.fontSize,
                    color: Colors.red,
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
      } else {
        //แสดงสีป้อนข้อมูล
        if (phoneCth.text.isEmpty) {
          setState(() {
            textPhoneWarningIsEmpty = 'ff0000';
            checkTextPhoneWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPhoneWarningIsEmpty = '898989';
            checkTextPhoneWarningIsEmpty = false;
          });
        }
        if (nameCth.text.isEmpty) {
          setState(() {
            textNameWarningIsEmpty = 'ff0000';
            checkTextNameWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textNameWarningIsEmpty = '898989';
            checkTextNameWarningIsEmpty = false;
          });
        }
        if (passwordCth.text.isEmpty) {
          setState(() {
            textPasswordWarningIsEmpty = 'ff0000';
            checkTextPasswordWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPasswordWarningIsEmpty = '898989';
            checkTextPasswordWarningIsEmpty = false;
          });
        }
        if (passwordCheckCtl.text.isEmpty) {
          setState(() {
            textPasswordCheckWarningIsEmpty = 'ff0000';
            checkTextPasswordCheckWarningIsEmpty = true;
          });
        } else {
          setState(() {
            textPasswordCheckWarningIsEmpty = '898989';
            checkTextPasswordCheckWarningIsEmpty = false;
          });
        }
        if (addressCtl.text.isEmpty) {
          setState(() {
            textAddressWarningIsEmpty = 'ff0000';
            checkTextAddressWarningIsEmpty = true;
            if (sameLocationAaddressText.text == 'เลือกตำแหน่ง') {
              textsameLocationAaddressWarningIsEmpty = 'ff0000';
              checkTextsameLocationAaddressWarningIsEmpty = true;
            }
          });
        } else {
          setState(() {
            textAddressWarningIsEmpty = '898989';
            checkTextAddressWarningIsEmpty = false;
          });
        }
        if (sameLocationAaddressText.text.isEmpty) {
          setState(() {
            textsameLocationAaddressWarningIsEmpty = 'ff0000';
            checkTextsameLocationAaddressWarningIsEmpty = true;
          });
        } else {
          setState(() {
            if (sameLocationAaddressText.text == 'เลือกตำแหน่ง') {
              textsameLocationAaddressWarningIsEmpty = 'ff0000';
              checkTextsameLocationAaddressWarningIsEmpty = true;
            } else {
              textsameLocationAaddressWarningIsEmpty = '898989';
              checkTextsameLocationAaddressWarningIsEmpty = false;
            }
          });
        }
      }
    }
  }

  void login() {
    Get.to(() => const LoginPage());
  }

  void locationSelected() async {
    // ใช้ width สำหรับ horizontal
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    double height = MediaQuery.of(context).size.height;

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
            // width: width,
            child: Column(
              children: [
                Row(
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
                ElevatedButton(
                  onPressed: () => presstousecurrentlocation(context),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      width * 0.8,
                      height * 0.05,
                    ),
                    backgroundColor: const Color(0xffFEF7E7),
                    elevation: 2, //เงาล่าง
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // มุมโค้งมน
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.string(
                        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2C7.589 2 4 5.589 4 9.995 3.971 16.44 11.696 21.784 12 22c0 0 8.029-5.56 8-12 0-4.411-3.589-8-8-8zm0 12c-2.21 0-4-1.79-4-4s1.79-4 4-4 4 1.79 4 4-1.79 4-4 4z"></path></svg>',
                        color: Colors.red,
                      ),
                      Text(
                        'ใช้ตำแหน่งปัจจุบัน',
                        style: TextStyle(
                          fontSize: Get.textTheme.titleMedium!.fontSize,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Text(
                      'จังหวัด',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: provinces.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: InkWell(
                              onTap: () {
                                selectedProvince = provinces[index];
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.01,
                                ),
                                child: Text(provinces[index]),
                              ),
                            ),
                          ),
                          const Divider(
                            // เส้นแบ่งระหว่างจังหวัด
                            color: Colors.grey, // สีของเส้นแบ่ง
                            thickness: 1, // ความหนาของเส้นแบ่ง
                            height: 0,
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void presstousecurrentlocation(context) async {
    // เรียกใช้ฟังก์ชันเพื่อรับข้อมูลจังหวัด, อำเภอ, ตำบล, ข้อมูลรหัสไปรษณีย์
    try {
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
              'กำลังค้นหาตำแหน่ง..',
              style: TextStyle(
                fontSize: Get.textTheme.titleLarge!.fontSize,
                color: const Color(0xffaf4c31),
              ),
            ),
            Text(
              'เรากำลังค้นหาตำแหน่ง กรุณารอสักครู่...',
              style: TextStyle(
                fontSize: Get.textTheme.titleSmall!.fontSize,
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      Position position = await _determinePosition();
      Map<String, String> locationDetails =
          await getLocationDetailsFromCoordinates(
              position.latitude, position.longitude);
      latlng.text = '${position.latitude},${position.longitude}';
      sameLocationAaddressText.text =
          '${locationDetails['province']} ${locationDetails['district']} ${locationDetails['subDistrict']} ${locationDetails['postalCode']}';
      sameLocationAaddress = false;
      textsameLocationAaddressWarningIsEmpty = '000000';
      checkTextsameLocationAaddressWarningIsEmpty = false;
      setState(() {});
    } catch (e) {
      Get.back();
    } finally {
      Get.back();
    }
  }

  Future<Map<String, String>> getLocationDetailsFromCoordinates(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&language=th&key=AIzaSyCCO43655qj2NvMx-o765XuddYontDAvRk'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['results'].isNotEmpty) {
        String province = '';
        String district = '';
        String subDistrict = '';
        String postalCode = '';

        for (var component in jsonData['results'][0]['address_components']) {
          if (component['types'].contains('administrative_area_level_1')) {
            province = component['long_name']; // จังหวัด
          }
          if (component['types'].contains('administrative_area_level_2')) {
            district = component['long_name']; // อำเภอ
          }
          if (component['types'].contains('sublocality_level_1') ||
              component['types'].contains('locality')) {
            subDistrict = component['long_name']; // ตำบล
          }
          if (component['types'].contains('postal_code')) {
            postalCode = component['long_name']; // ตำบล
          }
        }

        return {
          'province': province.isNotEmpty ? province : 'ไม่พบข้อมูลจังหวัด',
          'district': district.isNotEmpty ? district : 'ไม่พบข้อมูลอำเภอ',
          'subDistrict':
              subDistrict.isNotEmpty ? subDistrict : 'ไม่พบข้อมูลตำบล',
          'postalCode':
              postalCode.isNotEmpty ? postalCode : 'ไม่พบข้อมูลรหัสไปรษณีย์',
        };
      } else {
        return {
          'province': 'ไม่พบข้อมูลจังหวัด',
          'district': 'ไม่พบข้อมูลอำเภอ',
          'subDistrict': 'ไม่พบข้อมูลตำบล',
          'postalCode': 'ไม่พบข้อมูลรหัสไปรษณีย์',
        };
      }
    } else {
      throw Exception('Failed to load location details');
    }
  }

  Future<Map<String, double>> getLatLngFromAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&components=country:TH&key=AIzaSyCCO43655qj2NvMx-o765XuddYontDAvRk'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['results'].isNotEmpty) {
        final location = jsonData['results'][0]['geometry']['location'];
        final double lat = location['lat'];
        final double lng = location['lng'];

        return {
          'lat': lat,
          'lng': lng,
        }; // คืนค่า lat และ lng เป็น Map<String, double>
      } else {
        throw Exception('ไม่พบข้อมูลพิกัดสำหรับที่อยู่นี้');
      }
    } else {
      throw Exception('Failed to get location');
    }
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
