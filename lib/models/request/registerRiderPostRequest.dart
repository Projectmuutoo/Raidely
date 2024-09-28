// To parse this JSON data, do
//
//     final registerRiderPostRequest = registerRiderPostRequestFromJson(jsonString);

import 'dart:convert';

RegisterRiderPostRequest registerRiderPostRequestFromJson(String str) =>
    RegisterRiderPostRequest.fromJson(json.decode(str));

String registerRiderPostRequestToJson(RegisterRiderPostRequest data) =>
    json.encode(data.toJson());

class RegisterRiderPostRequest {
  String name;
  String phone;
  String password;
  String plate;
  String imageRider;

  RegisterRiderPostRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.plate,
    required this.imageRider,
  });

  factory RegisterRiderPostRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRiderPostRequest(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        plate: json["plate"],
        imageRider: json["image_rider"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "password": password,
        "plate": plate,
        "image_rider": imageRider,
      };
}
