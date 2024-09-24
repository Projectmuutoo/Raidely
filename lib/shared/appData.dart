import 'package:flutter/material.dart';

class Appdata with ChangeNotifier {
  late UserProfile user;
  String userEmail = '';
  int userId = 0;
}

class UserProfile {
  int idx = 0;
  String fullname = '';
}
