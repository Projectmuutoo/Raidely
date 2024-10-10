import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController nameShipping = TextEditingController();

  @override
  void initState() {
    loadData = loadDataAsync();
    super.initState();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'].toString();
    var phone = context.read<Appdata>().loginKeepUsers.phone;

    var responseCourierMember = await http.get(Uri.parse('$url/member/$phone'));
    var courierMember =
        byPhoneMemberGetResponseFromJson(responseCourierMember.body);
    var responseReceiveMember =
        await http.get(Uri.parse('$url/member/${widget.receivePhones}'));
    var receiveMember =
        byPhoneMemberGetResponseFromJson(responseReceiveMember.body);

    combinedMembers = [...courierMember, ...receiveMember].toSet().toList();

    // log('Combined Members: ${combinedMembers.map((member) => member.toJson()).toList()}');
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
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Error: ${snapshot.error}'));
          // }
          // if (combinedMembers.isEmpty) {
          //   return const Center(child: Text('No members found.'));
          // }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameShipping,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: combinedMembers.length,
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
                //แสดงรูป
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
                        onPressed: gallaryPicture,
                        child: const Text('Gallery')),
                    FilledButton(
                        onPressed: cameraPicture, child: const Text('Camera')),
                  ],
                ),
                const SizedBox(height: 20),

                //button จุดรับสินค้า
                Column(
                  children: [
                    FilledButton(
                        onPressed: getGPS, child: const Text('จุดรับสินค้า'))
                  ],
                ),

                // buttonยืนยัน ยกเลิก
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

  void getGPS() {}

  void cameraPicture() async {
    XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void gallaryPicture() async {
    XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = selectedImage;
    });
  }
}
