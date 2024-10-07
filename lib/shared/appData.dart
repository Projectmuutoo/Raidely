import 'package:flutter/material.dart';

class Appdata with ChangeNotifier {
  late loginKeepUser loginKeepUsers;
  late keepLocation pickupLocations;
  late keepDidInTableDelivery DidInTableDelivery;
}

class loginKeepUser {
  String phone = '';
}

class keepLocation {
  String pickupLocation = '';
}

class keepDidInTableDelivery {
  String did = '';
}
