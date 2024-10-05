// To parse this JSON data, do
//
//     final updateRiderPutRequest = updateRiderPutRequestFromJson(jsonString);

import 'dart:convert';

UpdateRiderPutRequest updateRiderPutRequestFromJson(String str) =>
    UpdateRiderPutRequest.fromJson(json.decode(str));

String updateRiderPutRequestToJson(UpdateRiderPutRequest data) =>
    json.encode(data.toJson());

class UpdateRiderPutRequest {
  String name;
  String password;
  String plate;
  String imageRider;

  UpdateRiderPutRequest({
    required this.name,
    required this.password,
    required this.plate,
    required this.imageRider,
  });

  factory UpdateRiderPutRequest.fromJson(Map<String, dynamic> json) =>
      UpdateRiderPutRequest(
        name: json["name"],
        password: json["password"],
        plate: json["plate"],
        imageRider: json["image_rider"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "password": password,
        "plate": plate,
        "image_rider": imageRider,
      };
}
