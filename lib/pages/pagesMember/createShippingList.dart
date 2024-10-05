import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raidely/pages/pagesMember/detailslist.dart';

class CreateshippinglistPage extends StatefulWidget {
  const CreateshippinglistPage({super.key});

  @override
  State<CreateshippinglistPage> createState() => _CreateshippinglistPageState();
}

class _CreateshippinglistPageState extends State<CreateshippinglistPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'รายการส่งสินค้า',
          style: TextStyle(
            fontSize: Get.textTheme.headlineSmall!.fontSize,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: height * 0.05),
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const DetailsShippingList());
            },
            icon: Icon(Icons.add_circle),
            label: Text('สร้างรายการส่งสินค้า'), // Create Delivery List
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: height * 0.02,
              ),
              backgroundColor: Colors.brown, // Button background color
            ),
          ),
        ),
      ),
    );
  }
}
