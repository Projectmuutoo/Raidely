// To parse this JSON data, do
//
//     final registerMemberPostRequest = registerMemberPostRequestFromJson(jsonString);

import 'dart:convert';

RegisterMemberPostRequest registerMemberPostRequestFromJson(String str) =>
    RegisterMemberPostRequest.fromJson(json.decode(str));

String registerMemberPostRequestToJson(RegisterMemberPostRequest data) =>
    json.encode(data.toJson());

class RegisterMemberPostRequest {
  String name;
  String phone;
  String password;
  String address;
  String gps;
  String imageMember;

  RegisterMemberPostRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.address,
    required this.gps,
    required this.imageMember,
  });

  factory RegisterMemberPostRequest.fromJson(Map<String, dynamic> json) =>
      RegisterMemberPostRequest(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        address: json["address"],
        gps: json["gps"],
        imageMember: json["image_member"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "password": password,
        "address": address,
        "gps": gps,
        "image_member": imageMember,
      };
}
