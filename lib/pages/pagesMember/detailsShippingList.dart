import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
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
  XFile? image;
  ImagePicker picker = ImagePicker();
  TextEditingController nameProductCth = TextEditingController();
  TextEditingController nameShippingCth = TextEditingController();
  TextEditingController namePhoneCth = TextEditingController();
  LatLng? currentPosition;
  LatLng? markerPosition;
  GoogleMapController? mapController;
  bool isTyping = false;
  String address = '';

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
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Center(
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
                                    hintText: isTyping ? '' : 'ป้อนชื่อสินค้า',
                                    hintStyle: TextStyle(
                                      fontSize:
                                          Get.textTheme.titleMedium!.fontSize,
                                      color: const Color(0xff898989),
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
                                        'ชื่อผู้รับ:',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: nameShippingCth,
                                        keyboardType: TextInputType.text,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          hintText: isTyping
                                              ? ''
                                              : 'ป้อนชื่อผู้รับสินค้า',
                                          hintStyle: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: const Color(0xff898989),
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
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: width * 0.02),
                                      child: Text(
                                        'เบอร์โทรผู้รับ:',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: namePhoneCth,
                                        keyboardType: TextInputType.phone,
                                        cursorColor: Colors.black,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: isTyping
                                              ? ''
                                              : 'ป้อนเบอร์โทรผู้รับสินค้า',
                                          hintStyle: TextStyle(
                                            fontSize: Get.textTheme.titleMedium!
                                                .fontSize,
                                            color: const Color(0xff898989),
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
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: width * 0.02),
                                      child: Text(
                                        'ที่อยู่ผู้รับ:',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: width * 0.02),
                                      child: ElevatedButton(
                                        onPressed: () => showMap(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF3F3F3),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            address.isEmpty
                                                ? SvgPicture.string(
                                                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 14c2.206 0 4-1.794 4-4s-1.794-4-4-4-4 1.794-4 4 1.794 4 4 4zm0-6c1.103 0 2 .897 2 2s-.897 2-2 2-2-.897-2-2 .897-2 2-2z"></path><path d="M11.42 21.814a.998.998 0 0 0 1.16 0C12.884 21.599 20.029 16.44 20 10c0-4.411-3.589-8-8-8S4 5.589 4 9.995c-.029 6.445 7.116 11.604 7.42 11.819zM12 4c3.309 0 6 2.691 6 6.005.021 4.438-4.388 8.423-6 9.73-1.611-1.308-6.021-5.294-6-9.735 0-3.309 2.691-6 6-6z"></path></svg>',
                                                  )
                                                : SvgPicture.string(
                                                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="m10 15.586-3.293-3.293-1.414 1.414L10 18.414l9.707-9.707-1.414-1.414z"></path></svg>',
                                                  ),
                                            Text(
                                              address.isEmpty
                                                  ? 'เลือกตำแหน่งที่อยู่'
                                                  : 'เลือกตำแหน่งแล้ว',
                                              style: TextStyle(
                                                fontSize: Get.textTheme
                                                    .titleMedium?.fontSize,
                                                color: const Color(0xff898989),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.01),
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.01),
                                InkWell(
                                  onTap: () {},
                                  child: SizedBox(
                                    width: width * 0.7,
                                    height: height * 0.2,
                                    child: DottedBorder(
                                      color: Colors.black, // สีของเส้นขอบ
                                      strokeWidth: 1,
                                      dashPattern: const [5, 5],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                children: [
                                                  // Container for the outer circle
                                                  Container(
                                                    height: height * 0.08,
                                                    width: width * 0.08,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xffd9d9d9),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          // White inner circle
                                                          Container(
                                                            height:
                                                                height * 0.08,
                                                            width: width * 0.08,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          // Inner gray circle
                                                          Container(
                                                            height:
                                                                height * 0.06,
                                                            width: width * 0.06,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffd9d9d9),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          // SVG Icon
                                                          SvgPicture.string(
                                                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="fill: rgba(0, 0, 0, 1);transform: ;msFilter:;"><path d="M12 8c-2.168 0-4 1.832-4 4s1.832 4 4 4 4-1.832 4-4-1.832-4-4-4zm0 6c-1.065 0-2-.935-2-2s.935-2 2-2 2 .935 2 2-.935 2-2 2z"></path><path d="M20 5h-2.586l-2.707-2.707A.996.996 0 0 0 14 2h-4a.996.996 0 0 0-.707.293L6.586 5H4c-1.103 0-2 .897-2 2v11c0 1.103.897 2 2 2h16c1.103 0 2-.897 2-2V7c0-1.103-.897-2-2-2zM4 18V7h3c.266 0 .52-.105.707-.293L10.414 4h3.172l2.707 2.707A.996.996 0 0 0 17 7h3l.002 11H4z"></path></svg>',
                                                            height:
                                                                height * 0.02,
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
                                                        color: const Color(
                                                            0xff898989),
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
                                        'ชื่อผู้ส่ง: ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        combinedMembers[1].name,
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                          color: const Color(0xFF626262),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'เบอร์โทรผู้ส่ง: ',
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                        ),
                                      ),
                                      Text(
                                        combinedMembers[1].phone,
                                        style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                          color: const Color(0xFF626262),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> cameraPicture() async {
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  Future<void> galleryPicture() async {
    final selectedImage = await picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        image = selectedImage;
      });
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
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: currentPosition!,
                            zoom: 15,
                          ),
                          markers: {
                            if (markerPosition != null)
                              Marker(
                                markerId: const MarkerId('currentLocation'),
                                position: markerPosition!,
                                infoWindow:
                                    const InfoWindow(title: 'Your Location'),
                              ),
                          },
                          onTap: (LatLng latLng) {
                            snapshot(() {
                              markerPosition = latLng;
                            });
                            mapController?.animateCamera(
                                CameraUpdate.newLatLng(markerPosition!));
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: const Text('Current Location'),
                            onPressed: () {
                              if (currentPosition != null) {
                                setState(() {
                                  markerPosition = currentPosition;
                                });
                                mapController?.animateCamera(
                                    CameraUpdate.newLatLng(currentPosition!));
                              }
                            },
                          ),
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () => Get.back(),
                          ),
                          TextButton(
                            child: const Text('Confirm'),
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
                                    address =
                                        '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
                                  });
                                  Get.back();
                                }
                              }
                            },
                          ),
                        ],
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
