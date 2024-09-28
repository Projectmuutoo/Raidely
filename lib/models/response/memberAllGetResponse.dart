// To parse this JSON data, do
//
//     final memberAllGetResponse = memberAllGetResponseFromJson(jsonString);

import 'dart:convert';

List<MemberAllGetResponse> memberAllGetResponseFromJson(String str) =>
    List<MemberAllGetResponse>.from(
        json.decode(str).map((x) => MemberAllGetResponse.fromJson(x)));

String memberAllGetResponseToJson(List<MemberAllGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MemberAllGetResponse {
  int mid;
  String name;
  String phone;
  String password;
  String address;
  String gps;
  String imageMember;
  String type;

  MemberAllGetResponse({
    required this.mid,
    required this.name,
    required this.phone,
    required this.password,
    required this.address,
    required this.gps,
    required this.imageMember,
    required this.type,
  });

  factory MemberAllGetResponse.fromJson(Map<String, dynamic> json) =>
      MemberAllGetResponse(
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
