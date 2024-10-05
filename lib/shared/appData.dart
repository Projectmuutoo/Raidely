import 'package:flutter/material.dart';

class Appdata with ChangeNotifier {
  late loginKeepUser loginKeepUsers;
  late keepLocation pickupLocations;
}

class loginKeepUser {
  String phone = '';
}

class keepLocation {
  String pickupLocation = '';
}
