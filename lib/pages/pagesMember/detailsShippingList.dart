import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailsShippingList extends StatefulWidget {
  final String receivePhones;

  const DetailsShippingList(this.receivePhones, {super.key});

  @override
  State<DetailsShippingList> createState() => _DetailsShippingListState();
}

class _DetailsShippingListState extends State<DetailsShippingList> {
  late Future<void> loadData;
  List<ByPhoneMemberGetResponse> combinedMembers = [];
  XFile? image;
  final ImagePicker picker = ImagePicker();
  final TextEditingController nameShipping = TextEditingController();
  LatLng? currentPosition;
  LatLng? markerPosition;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  Future<void> loadDataAsync() async {
    final config = await Configuration.getConfig();
    final url = config['apiEndpoint'].toString();
    final phone = context.read<Appdata>().loginKeepUsers.phone;

    final responseCourierMember =
        await http.get(Uri.parse('$url/member/$phone'));
    final courierMember =
        byPhoneMemberGetResponseFromJson(responseCourierMember.body);
    final responseReceiveMember =
        await http.get(Uri.parse('$url/member/${widget.receivePhones}'));
    final receiveMember =
        byPhoneMemberGetResponseFromJson(responseReceiveMember.body);

    combinedMembers = [...courierMember, ...receiveMember].toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Shipping List'),
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (combinedMembers.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nameShipping,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อสินค้า',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: combinedMembers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final member = combinedMembers[index];
                      String titleLabel;
                      String subtitleLabel;
                      String address = member.address ?? 'No address';

                      if (index == 0) {
                        titleLabel = "ชื่อผู้ส่ง : ";
                        subtitleLabel =
                            "เบอร์ผู้ส่ง : ${member.phone ?? 'No phone'}";
                      } else if (index == 1) {
                        titleLabel = "ชื่อผู้รับ : ";
                        subtitleLabel =
                            "ที่อยู่ผู้รับ : $address\nเบอร์ผู้รับ : ${member.phone ?? 'No phone'}";
                      } else {
                        titleLabel = "ชื่อสมาชิก : ";
                        subtitleLabel =
                            "เบอร์สมาชิก : ${member.phone ?? 'No phone'}";
                      }

                      return ListTile(
                        title: Text(titleLabel + (member.name ?? 'Unnamed')),
                        subtitle: Text(subtitleLabel),
                      );
                    },
                  ),
                ),
                // แสดงรูป
                const SizedBox(height: 20),
                if (image != null)
                  Image.file(
                    File(image!.path),
                    height: 100,
                    width: 100,
                  ),
                const SizedBox(height: 20),

                // Buttons รูป
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: galleryPicture,
                      child: const Text('Gallery'),
                    ),
                    FilledButton(
                      onPressed: cameraPicture,
                      child: const Text('Camera'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Button จุดรับสินค้า
                FilledButton(
                  onPressed: getGPS,
                  child: const Text('จุดรับสินค้า'),
                ),

                // Button ยืนยัน ยกเลิก
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('ยืนยัน'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('ยกเลิก'),
                    ),
                  ],
                ),
              ],
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
      print('Location permissions are denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });

    showMap();
  }

  void showMap() {
    if (currentPosition != null) {
      markerPosition = currentPosition;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Current Location'),
            content: SizedBox(
              height: 400,
              width: 400,
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
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    ),
                },
                onTap: (LatLng latLng) {
                  setState(() {
                    markerPosition = latLng; // อัปเดตตำแหน่งของมาร์กเกอร์
                  });
                  mapController?.animateCamera(CameraUpdate.newLatLng(
                      markerPosition!)); // เคลื่อนที่กล้องไปที่ตำแหน่งใหม่
                  log('Marker moved to: ${latLng.latitude}, ${latLng.longitude}');
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Current Location'), // ปุ่มตำแหน่งปัจจุบัน
                onPressed: () {
                  if (currentPosition != null) {
                    // อัปเดต markerPosition ด้วยตำแหน่งปัจจุบัน
                    setState(() {
                      markerPosition = currentPosition;
                    });
                    // ปรับกล้องไปที่ตำแหน่งปัจจุบัน
                    mapController?.animateCamera(
                      CameraUpdate.newLatLng(currentPosition!),
                    );
                    log('Current Location set to marker: ${currentPosition!.latitude}, ${currentPosition!.longitude}');
                  }
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  if (markerPosition != null) {
                    getPointGpsToSender(markerPosition!);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  void getPointGpsToSender(LatLng position) {
    log('Selected GPS Position: ${position.latitude}, ${position.longitude}');
    // TODO: Send location to server
  }
}
