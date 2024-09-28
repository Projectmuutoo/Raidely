// To parse this JSON data, do
//
//     final byPhoneRiderGetResponse = byPhoneRiderGetResponseFromJson(jsonString);

import 'dart:convert';

List<ByPhoneRiderGetResponse> byPhoneRiderGetResponseFromJson(String str) =>
    List<ByPhoneRiderGetResponse>.from(
        json.decode(str).map((x) => ByPhoneRiderGetResponse.fromJson(x)));

String byPhoneRiderGetResponseToJson(List<ByPhoneRiderGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ByPhoneRiderGetResponse {
  int rid;
  String name;
  String phone;
  String password;
  String plate;
  String imageRider;
  String type;

  ByPhoneRiderGetResponse({
    required this.rid,
    required this.name,
    required this.phone,
    required this.password,
    required this.plate,
    required this.imageRider,
    required this.type,
  });

  factory ByPhoneRiderGetResponse.fromJson(Map<String, dynamic> json) =>
      ByPhoneRiderGetResponse(
        rid: json["rid"],
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        plate: json["plate"],
        imageRider: json["image_rider"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "rid": rid,
        "name": name,
        "phone": phone,
        "password": password,
        "plate": plate,
        "image_rider": imageRider,
        "type": type,
      };
}
