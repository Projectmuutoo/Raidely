// To parse this JSON data, do
//
//     final riderAllGetResponse = riderAllGetResponseFromJson(jsonString);

import 'dart:convert';

List<RiderAllGetResponse> riderAllGetResponseFromJson(String str) =>
    List<RiderAllGetResponse>.from(
        json.decode(str).map((x) => RiderAllGetResponse.fromJson(x)));

String riderAllGetResponseToJson(List<RiderAllGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RiderAllGetResponse {
  int rid;
  String name;
  String phone;
  String password;
  String plate;
  String imageRider;
  String type;

  RiderAllGetResponse({
    required this.rid,
    required this.name,
    required this.phone,
    required this.password,
    required this.plate,
    required this.imageRider,
    required this.type,
  });

  factory RiderAllGetResponse.fromJson(Map<String, dynamic> json) =>
      RiderAllGetResponse(
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
