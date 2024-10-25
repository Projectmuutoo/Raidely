import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/memberAllGetResponse.dart';
import 'package:raidely/models/response/riderAllGetResponse.dart';
import 'package:raidely/pages/pagesMember/navbottompages.dart';
import 'package:raidely/pages/pagesRider/homeRider.dart';
import 'package:raidely/pages/register.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/shared/appData.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String textPhoneWarningIsEmpty = '898989';
  String textPasswordWarningIsEmpty = '898989';
  bool checkTextPhoneWarningIsEmpty = false;
  bool checkTextPasswordWarningIsEmpty = false;
  TextEditingController phoneCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  bool isTyping = false;
  bool _isCheckedPassword = true;
  late Future<void> loadData;
  final box = GetStorage();

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
        appBar: null,
        body: Stack(
          children: [
            // สร้างพื้นหลังส่วนบน
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: TrianglePainterTop(
                  const Color(0xffFEF7E7),
                ), // สีของสามเหลี่ยม
                size: Size(width, height * 0.3), // ขนาดของสามเหลี่ยม
              ),
            ),
            // สร้างพื้นหลังส่วนล่าง
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: TrianglePainterBottom(
                  const Color(0xffFEF7E7),
                ), // สีของสามเหลี่ยม
                size: Size(width, height * 0.3), // ขนาดของสามเหลี่ยม
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/green.png',
                        height: height * 0.2,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        'RaiDely',
                        style: TextStyle(
                          fontSize: Get.textTheme.headlineMedium!.fontSize,
                          shadows: const [
                            Shadow(
                              blurRadius: 6,
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
                              top: height * 0.02,
                            ),
                            child: Text(
                              'หมายเลขโทรศัพท์',
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                              ),
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
                                hintText:
                                    isTyping ? '' : 'ป้อนหมายเลขโทรศัพท์ของคุณ',
                                hintStyle: TextStyle(
                                  fontSize: Get.textTheme.titleSmall!.fontSize,
                                  color: Color(
                                    int.parse('0xff$textPhoneWarningIsEmpty'),
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: height * 0.05,
                                ),
                                contentPadding: !checkTextPhoneWarningIsEmpty
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
                              top: height * 0.01,
                            ),
                            child: Text(
                              'รหัสผ่าน',
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                              ),
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
                                  fontSize: Get.textTheme.titleSmall!.fontSize,
                                  color: Color(
                                    int.parse(
                                        '0xff$textPasswordWarningIsEmpty'),
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: height * 0.05,
                                ),
                                contentPadding: !checkTextPasswordWarningIsEmpty
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
                      SizedBox(height: height * 0.04),
                      ElevatedButton(
                        onPressed: login,
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
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: width * 0.01,
                            ),
                            child: Text(
                              "หากคุณไม่มีบัญชี?",
                              style: TextStyle(
                                fontSize: Get.textTheme.titleSmall!.fontSize,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: register,
                            child: SizedBox(
                              child: Text(
                                "สมัครสมาชิก",
                                style: TextStyle(
                                  fontSize: Get.textTheme.titleSmall!.fontSize,
                                  color: const Color(0xff4696C1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void register() {
    Get.to(() => const RegisterPage());
  }

  void login() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var responseMember = await http.get(Uri.parse('$url/member'));
    var responseRider = await http.get(Uri.parse('$url/rider'));
    if (phoneCth.text.isNotEmpty && passwordCth.text.isNotEmpty) {
      //แสดงสีป้อนข้อมูลเดิม
      setState(() {
        textPhoneWarningIsEmpty = '898989';
        textPasswordWarningIsEmpty = '898989';
        checkTextPhoneWarningIsEmpty = false;
        checkTextPasswordWarningIsEmpty = false;
      });

      var memberAllResponse = memberAllGetResponseFromJson(responseMember.body);
      var riderAllResponse = riderAllGetResponseFromJson(responseRider.body);
      //เก็บ phone,password ของ members,rider ทุกคนมา
      var phoneMembers = memberAllResponse.map((value) => value.phone).toList();
      var passwordMembers =
          memberAllResponse.map((value) => value.password).toList();
      var phoneRiders = riderAllResponse.map((value) => value.phone).toList();
      var passwordRiders =
          riderAllResponse.map((value) => value.password).toList();
      //ถ้าหาก phoneMembers,phoneRiders ตรงกันกับที่ user พิมมา
      if (phoneMembers.contains(phoneCth.text) ||
          phoneRiders.contains(phoneCth.text)) {
        //ถ้าหาก passwordMembers,passwordRiders ตรงกันกับที่ user พิมมา
        if (passwordMembers.contains(passwordCth.text) ||
            passwordRiders.contains(passwordCth.text)) {
          //ถ้าหาก phoneMembers เป็น true
          if (phoneMembers.contains(phoneCth.text)) {
            LoginKeepUser users = LoginKeepUser();
            users.phone = phoneCth.text.toString();
            context.read<Appdata>().loginKeepUsers = users;
            if (box.read('pickupLocation') == null) {
              KeepLocation keep = KeepLocation();
              keep.pickupLocation = '-';
              context.read<Appdata>().pickupLocations = keep;
            } else {
              KeepLocation keep = KeepLocation();
              keep.pickupLocation = box.read('pickupLocation');
              context.read<Appdata>().pickupLocations = keep;
            }
            Get.to(
              () => NavbottompagesPage(selectedPage: 1),
            );
          }
          //ถ้าหาก phoneRiders เป็น true
          if (phoneRiders.contains(phoneCth.text)) {
            LoginKeepUser users = LoginKeepUser();
            users.phone = phoneCth.text.toString();
            context.read<Appdata>().loginKeepUsers = users;
            Get.to(() => const HomeriderPage());
          }
        } else {
          //แจ้งเตือนป้อนข้อมูล password ไม่ตรงกับ ที่มีอยู่ใน database
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
                  'รหัสผ่านของคุณไม่ถูกต้อง!',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                Text(
                  'ตรวจสอบรหัสผ่านอีกครั้ง.',
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
        //แจ้งเตือนป้อนข้อมูล phone ไม่ตรงกับ ที่มีอยู่ใน database
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
                'ไม่พบหมายเลขโทรศัพท์นี้!',
                style: TextStyle(
                  fontSize: Get.textTheme.titleLarge!.fontSize,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.02),
              Text(
                'ตรวจสอบหมายเลขโทรศัพท์อีกครั้ง.',
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
    }
  }
}

//สามเหลี่ยม background บน
class TrianglePainterTop extends CustomPainter {
  final Color color;

  TrianglePainterTop(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(size.width * 1.5, 0) // จุดเริ่มต้นที่มุมบนขวา
      ..lineTo(0, 0) // เส้นไปยังมุมบนซ้าย
      ..lineTo(0, size.height * 1.2) // เส้นไปยังมุมซ้ายล่าง
      ..close(); // ปิดเส้นทางเพื่อวาดสามเหลี่ยม

    canvas.drawPath(path, paint); // วาดสามเหลี่ยมบน canvas
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//สามเหลี่ยม background ล่าง
class TrianglePainterBottom extends CustomPainter {
  final Color color;

  TrianglePainterBottom(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(0, size.height * 1.06) // จุดเริ่มต้นที่มุมล่างซ้าย
      ..lineTo(size.width, size.height) // เส้นไปยังมุมล่างขวา
      ..lineTo(size.height * 2, 0) // เส้นจากมุมล่างขวาไปยังกึ่งกลางบนสุด
      ..close(); // ปิดเส้นทางเพื่อวาดสามเหลี่ยม

    canvas.drawPath(path, paint); // วาดสามเหลี่ยมบน canvas
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
