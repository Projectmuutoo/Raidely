import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:raidely/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController phoneCth = TextEditingController();
  TextEditingController nameCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  TextEditingController addressCtl = TextEditingController();
  bool isTyping = false;
  bool _isCheckedPassword = true;
  bool sameLocationAaddress = false;

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
                Get.to(() => const LoginPage());
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
                fontSize: Get.textTheme.headlineSmall!.fontSize,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  log('hi');
                },
                child: Container(
                  height: height * 0.1,
                  width: width * 0.25,
                  decoration: const BoxDecoration(
                    color: Colors.red,
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
              SizedBox(height: height * 0.02),
              Text(
                'ธเนดดดดด',
                style: TextStyle(
                  fontSize: Get.textTheme.headlineMedium!.fontSize,
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
                            fontSize: Get.textTheme.titleLarge!.fontSize,
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
                  controller: phoneCth,
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.black,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    hintText: isTyping ? '' : 'ป้อนหมายเลขโทรศัพท์ของคุณ',
                    hintStyle: TextStyle(
                      fontSize: Get.textTheme.titleMedium!.fontSize,
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
                            fontSize: Get.textTheme.titleLarge!.fontSize,
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
                  controller: nameCth,
                  keyboardType: TextInputType.name,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: isTyping ? '' : 'ป้อนชื่อของคุณ',
                    hintStyle: TextStyle(
                      fontSize: Get.textTheme.titleMedium!.fontSize,
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
                            fontSize: Get.textTheme.titleLarge!.fontSize,
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
                          _isCheckedPassword = !_isCheckedPassword;
                        });
                      },
                    ),
                    hintText: isTyping ? '' : 'ป้อนรหัสผ่านของคุณ',
                    hintStyle: TextStyle(
                      fontSize: Get.textTheme.titleMedium!.fontSize,
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
                            fontSize: Get.textTheme.titleLarge!.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    hintText: isTyping
                        ? ''
                        : 'บ้านเลขที่, ซอย, หมู่, ถนน, แขวง/ตำบล,\n เขต/อำเภอ, จังหวัด, รหัสไปรษณีย์',
                    hintStyle: TextStyle(
                      fontSize: Get.textTheme.titleMedium!.fontSize,
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
              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.03,
                  bottom: height * 0.002,
                  right: width * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'สถานที่รับสินค้า ',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  sameLocationAsAaddress(!sameLocationAaddress);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical: height * 0.005,
                                  ),
                                  child: SizedBox(
                                    child: Text(
                                      'ตำแหน่งเดียวกับที่อยู่',
                                      style: TextStyle(
                                        fontSize:
                                            Get.textTheme.titleSmall!.fontSize,
                                        color: const Color(0xff898989),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: 1.1,
                                child: SizedBox(
                                  width: width * 0.04,
                                  height: height * 0.04,
                                  child: Checkbox(
                                    activeColor: const Color(0xFF51281D),
                                    value: sameLocationAaddress,
                                    onChanged: (bool? value) {
                                      sameLocationAsAaddress(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  locationSelected(context);
                },
                style: TextButton.styleFrom(
                  fixedSize: Size(
                    width,
                    height * 0.05,
                  ),
                  backgroundColor: const Color(0xff8B8B8B),
                  elevation: 3, //เงาล่าง
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // มุมโค้งมน
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.string(
                      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 14c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2z"></path><path d="M11.42 21.814a.998.998 0 0 0 1.16 0C12.884 21.599 20.029 16.44 20 10c0-4.411-3.589-8-8-8S4 5.589 4 9.995c-.029 6.445 7.116 11.604 7.42 11.819zM12 4c3.309 0 6 2.691 6 6.005.021 4.438-4.388 8.423-6 9.73-1.611-1.308-6.021-5.294-6-9.735 0-3.309 2.691-6 6-6z"></path></svg>',
                    ),
                    Text(
                      "เลือกตำแหน่ง",
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(
                    width * 0.4,
                    height * 0.05,
                  ),
                  backgroundColor: const Color(0xffFEF7E7),
                  elevation: 3, //เงาล่าง
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // มุมโค้งมน
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
              SizedBox(height: height * 0.04),
              InkWell(
                onTap: () {
                  Get.to(() => const LoginPage());
                },
                child: Text(
                  "ออกจากระบบ",
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sameLocationAsAaddress(bool? value) {
    setState(() {
      sameLocationAaddress = value ?? !sameLocationAaddress;
    });
  }

  void locationSelected(context) {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                          height: height * 0.032,
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
    );
  }
}
