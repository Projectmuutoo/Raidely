import 'package:flutter/material.dart';

class Appdata with ChangeNotifier {
  late LoginKeepUser loginKeepUsers;
  late KeepLocation pickupLocations;
  late KeepDidInTableDelivery didInTableDelivery;
  late KeepPhoneFileDetailsShippingList phoneFileDetailsShippingList;
  late KeepDidFileShippingStatus didFileShippingStatus;
}

class LoginKeepUser {
  String phone = '';
}

class KeepLocation {
  String pickupLocation = '';
}

class KeepDidInTableDelivery {
  String did = '';
}

class KeepPhoneFileDetailsShippingList {
  String phone = '';
}

class KeepDidFileShippingStatus {
  String did = '';
}
