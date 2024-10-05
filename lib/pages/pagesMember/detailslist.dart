import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailsShippingList extends StatefulWidget {
  const DetailsShippingList({super.key});

  @override
  State<DetailsShippingList> createState() => _DetailsShippingListState();
}

class _DetailsShippingListState extends State<DetailsShippingList> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "รายละเอียดสินค้าที่ส่ง"), // Details of the shipped product
        backgroundColor: Colors.brown, // Change this color as needed
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around the content
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Text(
                "ชื่อสินค้า: คอมตั้งโต๊ะ", // Product Name
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Recipient Name
              Text(
                "ชื่อผู้รับ: ธเนด สรรพสิทธิ์", // Recipient Name
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Recipient Address
              Text(
                "ที่อยู่ผู้รับ: 999/27 ซอยคลีโอรณ์ ตำบลเขาย้อย จังหวัดเพชรบุรี 44150", // Recipient Address
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Phone Number
              Text(
                "เบอร์โทรผู้รับ: 0625500464", // Recipient Phone Number
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Image Placeholder
              Container(
                height: height * 0.25,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "แผนบูรณ์สินค้า", // Product Image Placeholder
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Confirm and Cancel buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle confirm action
                    },
                    child: Text("ยืนยัน"), // Confirm
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Handle cancel action
                      Navigator.pop(context); // Go back to the previous page
                    },
                    child: Text("ยกเลิก"), // Cancel
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
