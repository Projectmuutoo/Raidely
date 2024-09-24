import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListproductsreceivedPage extends StatefulWidget {
  const ListproductsreceivedPage({super.key});

  @override
  State<ListproductsreceivedPage> createState() =>
      _ListproductsreceivedPageState();
}

class _ListproductsreceivedPageState extends State<ListproductsreceivedPage> {
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
