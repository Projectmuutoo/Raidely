// To parse this JSON data, do
//
//     final insertRiderAssignment = insertRiderAssignmentFromJson(jsonString);

import 'dart:convert';

InsertRiderAssignment insertRiderAssignmentFromJson(String str) =>
    InsertRiderAssignment.fromJson(json.decode(str));

String insertRiderAssignmentToJson(InsertRiderAssignment data) =>
    json.encode(data.toJson());

class InsertRiderAssignment {
  int raid;
  int deliveryId;
  int riderId;
  String status;
  String imageReceiver;
  String imageSuccess;

  InsertRiderAssignment({
    required this.raid,
    required this.deliveryId,
    required this.riderId,
    required this.status,
    required this.imageReceiver,
    required this.imageSuccess,
  });

  factory InsertRiderAssignment.fromJson(Map<String, dynamic> json) =>
      InsertRiderAssignment(
        raid: json["raid"],
        deliveryId: json["delivery_id"],
        riderId: json["rider_id"],
        status: json["status"],
        imageReceiver: json["image_receiver"],
        imageSuccess: json["image_success"],
      );

  Map<String, dynamic> toJson() => {
        "raid": raid,
        "delivery_id": deliveryId,
        "rider_id": riderId,
        "status": status,
        "image_receiver": imageReceiver,
        "image_success": imageSuccess,
      };
}
