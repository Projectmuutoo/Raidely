// To parse this JSON data, do
//
//     final byPhoneMemberGetResponse = byPhoneMemberGetResponseFromJson(jsonString);

import 'dart:convert';

List<ByPhoneMemberGetResponse> byPhoneMemberGetResponseFromJson(String str) =>
    List<ByPhoneMemberGetResponse>.from(
        json.decode(str).map((x) => ByPhoneMemberGetResponse.fromJson(x)));

String byPhoneMemberGetResponseToJson(List<ByPhoneMemberGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ByPhoneMemberGetResponse {
  int mid;
  String name;
  String phone;
  String password;
  String address;
  String gps;
  String imageMember;
  String type;

  ByPhoneMemberGetResponse({
    required this.mid,
    required this.name,
    required this.phone,
    required this.password,
    required this.address,
    required this.gps,
    required this.imageMember,
    required this.type,
  });

  factory ByPhoneMemberGetResponse.fromJson(Map<String, dynamic> json) =>
      ByPhoneMemberGetResponse(
        mid: json["mid"],
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        address: json["address"],
        gps: json["gps"],
        imageMember: json["image_member"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "name": name,
        "phone": phone,
        "password": password,
        "address": address,
        "gps": gps,
        "image_member": imageMember,
        "type": type,
      };
}
