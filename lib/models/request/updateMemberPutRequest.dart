// To parse this JSON data, do
//
//     final updateMemberPutRequest = updateMemberPutRequestFromJson(jsonString);

import 'dart:convert';

UpdateMemberPutRequest updateMemberPutRequestFromJson(String str) =>
    UpdateMemberPutRequest.fromJson(json.decode(str));

String updateMemberPutRequestToJson(UpdateMemberPutRequest data) =>
    json.encode(data.toJson());

class UpdateMemberPutRequest {
  String name;
  String password;
  String address;
  String gps;
  String imageMember;

  UpdateMemberPutRequest({
    required this.name,
    required this.password,
    required this.address,
    required this.gps,
    required this.imageMember,
  });

  factory UpdateMemberPutRequest.fromJson(Map<String, dynamic> json) =>
      UpdateMemberPutRequest(
        name: json["name"],
        password: json["password"],
        address: json["address"],
        gps: json["gps"],
        imageMember: json["image_member"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "password": password,
        "address": address,
        "gps": gps,
        "image_member": imageMember,
      };
}
