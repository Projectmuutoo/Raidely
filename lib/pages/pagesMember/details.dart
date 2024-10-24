import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raidely/config/config.dart';
import 'package:raidely/models/response/byPhoneMemberGetResponse.dart';
import 'package:raidely/models/response/deliveryAllGetResponse.dart';
import 'package:raidely/models/response/deliveryGetDIDRespone.dart';
import 'package:raidely/shared/appData.dart';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final int did;
  const DetailsPage({super.key, required this.did});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? errorMessage;
  late List<ByPhoneMemberGetResponse> resultsResponseMemberBody = [];
  DeliveryAllGetDidResponse? deliveryAllGetResponse;
  bool isLoading = true; // Manage loading state

  @override
  void initState() {
    super.initState();
    loadDataAsync();
  }

  Future<void> loadDataAsync() async {
    try {
      var config = await Configuration.getConfig();
      var url = config['apiEndpoint'].toString();
      var apiKey = config['apiKey'];
      var phone = context.read<Appdata>().loginKeepUsers.phone;

      var responseMember = await http.get(Uri.parse('$url/member/$phone'));
      resultsResponseMemberBody =
          byPhoneMemberGetResponseFromJson(responseMember.body);

      var responseDelivery =
          await http.get(Uri.parse('$url/delivery/${widget.did}'));
      deliveryAllGetResponse =
          deliveryAllGetDidResponseFromJson(responseDelivery.body);

      // Handle empty response
      if (deliveryAllGetResponse == null) {
        errorMessage = 'No delivery details available.';
      }
    } catch (e) {
      errorMessage = e.toString(); // Capture error message
      log('Error fetching deliveries: $errorMessage'); // Log error
    } finally {
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า'),
      ),
      body: FutureBuilder(
        future: loadDataAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
