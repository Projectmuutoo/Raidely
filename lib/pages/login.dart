import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:raidely/pages/navpages/navbottompages.dart';
import 'package:raidely/pages/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneCth = TextEditingController();
  TextEditingController passwordCth = TextEditingController();
  bool isTyping = false;
  bool _isCheckedPassword = true;

  @override
  Widget build(BuildContext context) {
    // ใช้ width สำหรับ horizontal
    // left/right
    double width = MediaQuery.of(context).size.width;
    // ใช้ height สำหรับ vertical
    // top/bottom
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
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
                          top: height * 0.01,
                        ),
                        child: Text(
                          'หมายเลขโทรศัพท์',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
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
                        child: Text(
                          'รหัสผ่าน',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleLarge!.fontSize,
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
                        borderRadius: BorderRadius.circular(24), // มุมโค้งมน
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
                            fontSize: Get.textTheme.titleMedium!.fontSize,
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
                              fontSize: Get.textTheme.titleMedium!.fontSize,
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
        ],
      ),
    );
  }

  void register() {
    Get.to(() => const RegisterPage());
  }

  void login() {
    Get.to(
      () => NavbottompagesPage(
        selectedPage: 1,
      ),
    );
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
