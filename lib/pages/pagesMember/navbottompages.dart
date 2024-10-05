import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:raidely/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/pages/pagesMember/createShippingList.dart';
import 'package:raidely/pages/pagesMember/homeMember.dart';
import 'package:raidely/pages/pagesMember/listProductsReceived.dart';

class NavbottompagesPage extends StatefulWidget {
  int selectedPage = 0;
  NavbottompagesPage({
    super.key,
    required this.selectedPage,
  });

  @override
  State<NavbottompagesPage> createState() => _NavbottompagesPageState();
}

class _NavbottompagesPageState extends State<NavbottompagesPage> {
  late Future<void> loadData;
  late final List<Widget> pageOptions;

  @override
  void initState() {
    pageOptions = [
      CreateshippinglistPage(),
      HomeMemberPage(),
      ListproductsreceivedPage()
    ];
    loadData = loadDataAsync();
    super.initState();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
  }

  void onItemTapped(int index) {
    setState(() {
      widget.selectedPage = index;
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

    return FutureBuilder(
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
        return Scaffold(
          appBar: null,
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M22 8a.76.76 0 0 0 0-.21v-.08a.77.77 0 0 0-.07-.16.35.35 0 0 0-.05-.08l-.1-.13-.08-.06-.12-.09-9-5a1 1 0 0 0-1 0l-9 5-.09.07-.11.08a.41.41 0 0 0-.07.11.39.39 0 0 0-.08.1.59.59 0 0 0-.06.14.3.3 0 0 0 0 .1A.76.76 0 0 0 2 8v8a1 1 0 0 0 .52.87l9 5a.75.75 0 0 0 .13.06h.1a1.06 1.06 0 0 0 .5 0h.1l.14-.06 9-5A1 1 0 0 0 22 16V8zm-10 3.87L5.06 8l2.76-1.52 6.83 3.9zm0-7.72L18.94 8 16.7 9.25 9.87 5.34zM4 9.7l7 3.92v5.68l-7-3.89zm9 9.6v-5.68l3-1.68V15l2-1v-3.18l2-1.11v5.7z"></path></svg>',
                  width: width * 0.08,
                  height: width * 0.08,
                  fit: BoxFit.cover,
                  color: const Color(0xffAF4C31),
                ),
                activeIcon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M22 8a.76.76 0 0 0 0-.21v-.08a.77.77 0 0 0-.07-.16.35.35 0 0 0-.05-.08l-.1-.13-.08-.06-.12-.09-9-5a1 1 0 0 0-1 0l-9 5-.09.07-.11.08a.41.41 0 0 0-.07.11.39.39 0 0 0-.08.1.59.59 0 0 0-.06.14.3.3 0 0 0 0 .1A.76.76 0 0 0 2 8v8a1 1 0 0 0 .52.87l9 5a.75.75 0 0 0 .13.06h.1a1.06 1.06 0 0 0 .5 0h.1l.14-.06 9-5A1 1 0 0 0 22 16V8zm-10 3.87L5.06 8l2.76-1.52 6.83 3.9zm0-7.72L18.94 8 16.7 9.25 9.87 5.34zM4 9.7l7 3.92v5.68l-7-3.89zm9 9.6v-5.68l3-1.68V15l2-1v-3.18l2-1.11v5.7z"></path></svg>',
                  width: width * 0.082,
                  height: width * 0.082,
                  fit: BoxFit.cover,
                  color: const Color(0xff51281D),
                ),
                label: 'สร้างรายการส่งสินค้า',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#5f6368"><path d="M240-200h120v-240h240v240h120v-360L480-740 240-560v360Zm-80 80v-480l320-240 320 240v480H520v-240h-80v240H160Zm320-350Z"/></svg>',
                  width: width * 0.08,
                  height: width * 0.08,
                  fit: BoxFit.cover,
                  color: const Color(0xffAF4C31),
                ),
                activeIcon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#5f6368"><path d="M240-200h120v-240h240v240h120v-360L480-740 240-560v360Zm-80 80v-480l320-240 320 240v480H520v-240h-80v240H160Zm320-350Z"/></svg>',
                  width: width * 0.082,
                  height: width * 0.082,
                  fit: BoxFit.cover,
                  color: const Color(0xff51281D),
                ),
                label: 'หน้าหลัก',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#5f6368"><path d="M240-160q-50 0-85-35t-35-85H40v-440q0-33 23.5-56.5T120-800h560v160h120l120 160v200h-80q0 50-35 85t-85 35q-50 0-85-35t-35-85H360q0 50-35 85t-85 35Zm0-80q17 0 28.5-11.5T280-280q0-17-11.5-28.5T240-320q-17 0-28.5 11.5T200-280q0 17 11.5 28.5T240-240ZM120-360h32q17-18 39-29t49-11q27 0 49 11t39 29h272v-360H120v360Zm600 120q17 0 28.5-11.5T760-280q0-17-11.5-28.5T720-320q-17 0-28.5 11.5T680-280q0 17 11.5 28.5T720-240Zm-40-200h170l-90-120h-80v120ZM360-540Z"/></svg>',
                  width: width * 0.08,
                  height: width * 0.08,
                  fit: BoxFit.cover,
                  color: const Color(0xffAF4C31),
                ),
                activeIcon: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#5f6368"><path d="M240-160q-50 0-85-35t-35-85H40v-440q0-33 23.5-56.5T120-800h560v160h120l120 160v200h-80q0 50-35 85t-85 35q-50 0-85-35t-35-85H360q0 50-35 85t-85 35Zm0-80q17 0 28.5-11.5T280-280q0-17-11.5-28.5T240-320q-17 0-28.5 11.5T200-280q0 17 11.5 28.5T240-240ZM120-360h32q17-18 39-29t49-11q27 0 49 11t39 29h272v-360H120v360Zm600 120q17 0 28.5-11.5T760-280q0-17-11.5-28.5T720-320q-17 0-28.5 11.5T680-280q0 17 11.5 28.5T720-240Zm-40-200h170l-90-120h-80v120ZM360-540Z"/></svg>',
                  width: width * 0.082,
                  height: width * 0.082,
                  fit: BoxFit.cover,
                  color: const Color(0xff51281D),
                ),
                label: 'รายการสินค้าที่ได้รับ',
              ),
            ],
            currentIndex: widget.selectedPage,
            onTap: onItemTapped,
            selectedLabelStyle: TextStyle(
              fontSize: Get.textTheme.labelLarge!.fontSize,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: Get.textTheme.labelMedium!.fontSize,
            ),
            // showSelectedLabels: false,
            // showUnselectedLabels: false,
            backgroundColor: const Color(0xffFEF7E7),
            selectedItemColor: const Color(0xff51281D),
            unselectedItemColor: const Color(0xffAF4C31),
            type: BottomNavigationBarType.fixed,
          ),
          body: pageOptions[widget.selectedPage],
        );
      },
    );
  }
}
