import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateshippinglistPage extends StatefulWidget {
  const CreateshippinglistPage({super.key});

  @override
  State<CreateshippinglistPage> createState() => _CreateshippinglistPageState();
}

class _CreateshippinglistPageState extends State<CreateshippinglistPage> {
  @override
  Widget build(BuildContext context) {
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
      body: Container(),
    );
  }
}
