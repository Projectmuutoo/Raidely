import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneRiderGetResponse.dart';
import 'package:raidely/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:raidely/pages/pagesRider/getOrder.dart';
import 'package:raidely/shared/appData.dart';

class HomeriderPage extends StatefulWidget {
  const HomeriderPage({super.key});

  @override
  State<HomeriderPage> createState() => _HomeriderPageState();
}

class _HomeriderPageState extends State<HomeriderPage> {
  late Future<void> loadData;
  late List<ByPhoneRiderGetResponse> resultsResponseRiderBody = [];

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
                          Get.to(() => const LoginPage());
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
                                child: resultsResponseRiderBody[0].imageRider ==
                                        '-'
                                    ? SvgPicture.string(
                                        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3zm9 11v-1a7 7 0 0 0-7-7h-4a7 7 0 0 0-7 7v1h2v-1a5 5 0 0 1 5-5h4a5 5 0 0 1 5 5v1z"></path></svg>',
                                        height: height * 0.05,
                                        color: Colors.grey,
                                      )
                                    : Image.network(
                                        resultsResponseRiderBody[0].imageRider,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resultsResponseRiderBody[0].name,
                              style: TextStyle(
                                fontSize: Get.textTheme.titleMedium!.fontSize,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RefreshIndicator(
                    onRefresh: loadDataAsync,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          FilledButton(
                            onPressed: () {
                              Get.to(() => const GetorderPage());
                            },
                            child: Text('getOrder'),
                          ),
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
    );
  }
}
